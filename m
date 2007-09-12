From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/16] net: Make socket creation namespace safe.
Date: Wed, 12 Sep 2007 03:04:27 -0700 (PDT)
Message-ID: <20070912.030427.88485717.davem@davemloft.net>
References: <m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
	<m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:43272
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932860AbXILKEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:04:30 -0400
In-Reply-To: <m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:23:01 -0600

> 
> This patch passes in the namespace a new socket should be created in
> and has the socket code do the appropriate reference counting.  By
> virtue of this all socket create methods are touched.  In addition
> the socket create methods are modified so that they will fail if
> you attempt to create a socket in a non-default network namespace.
> 
> Failing if we attempt to create a socket outside of the default
> network namespace ensures that as we incrementally make the network stack
> network namespace aware we will not export functionality that someone
> has not audited and made certain is network namespace safe.
> Allowing us to partially enable network namespaces before all of the
> exotic protocols are supported.
> 
> Any protocol layers I have missed will fail to compile because I now
> pass an extra parameter into the socket creation code.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Patch applied, thanks.
