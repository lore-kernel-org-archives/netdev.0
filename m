From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/16] net: Add a network namespace tag to struct
 net_device
Date: Wed, 12 Sep 2007 02:57:09 -0700 (PDT)
Message-ID: <20070912.025709.21916551.davem@davemloft.net>
References: <m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:48289
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756023AbXILJ5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 05:57:12 -0400
In-Reply-To: <m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:18:12 -0600

> 
> Please note that network devices do not increase the count
> count on the network namespace.  The are inside the network
> namespace and so the network namespace tag is in the nature
> of a back pointer and so getting and putting the network namespace
> is unnecessary.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.
