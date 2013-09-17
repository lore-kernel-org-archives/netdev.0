From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCHv2 net] xen-netback: count number required slots for an
 skb more carefully
Date: Tue, 17 Sep 2013 17:41:32 +0100
Message-ID: <5238863C.9050407@citrix.com>
References: <1378907568-8062-1-git-send-email-david.vrabel@citrix.com>	 <20130912.232328.1199260755421139102.davem@davemloft.net> <1379426727.11304.103.camel@hastur.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <xen-devel@lists.xen.org>,
	<konrad.wilk@oracle.com>, <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:33870 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404Ab3IQQle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 12:41:34 -0400
In-Reply-To: <1379426727.11304.103.camel@hastur.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/09/13 15:05, Ian Campbell wrote:
> On Thu, 2013-09-12 at 23:23 -0400, David Miller wrote:
>> I assume you want this queued up for -stable,
> 
> I think so, David V -- do you know how far back this goes?

Stable please, but only back to 3.10.

I suspect (but never had time to confirm) that this fixes a regression
introduced by "xen/netback: Calculate the number of SKB slots required
correctly" e26b203e which was added in 3.6.

>>  and can you check if
>> there is any non-trivial backporting for earlier kernels?
> 
> Another one I hope David can answer...

Backport to 3.10 "just works".

David
