From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/16] net: Make device event notification network
 namespace safe
Date: Wed, 12 Sep 2007 04:02:55 -0700 (PDT)
Message-ID: <20070912.040255.35673679.davem@davemloft.net>
References: <m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5r0voh4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy1ovoeo.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:44734
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965568AbXILLC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:02:58 -0400
In-Reply-To: <m1fy1ovoeo.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:27:11 -0600

> 
> Every user of the network device notifiers is either a protocol
> stack or a pseudo device.  If a protocol stack that does not have
> support for multiple network namespaces receives an event for a
> device that is not in the initial network namespace it quite possibly
> can get confused and do the wrong thing.
> 
> To avoid problems until all of the protocol stacks are converted
> this patch modifies all netdev event handlers to ignore events on
> devices that are not in the initial network namespace.
> 
> As the rest of the code is made network namespace aware these
> checks can be removed.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks.
