From: Jeff Haran <jharan@Brocade.COM>
Subject: RE: NETLINK sockets dont honor SO_RCVLOWAT?
Date: Wed, 18 Nov 2009 11:00:35 -0800
Message-ID: <D67825C5985D0647BE40A5F5B0B70D1106E9C5690C@HQ-EXCH-7.corp.brocade.com>
References: <D67825C5985D0647BE40A5F5B0B70D1106E9C568F1@HQ-EXCH-7.corp.brocade.com>
	<20091118.102434.160976750.davem@davemloft.net>
	<D67825C5985D0647BE40A5F5B0B70D1106E9C568FE@HQ-EXCH-7.corp.brocade.com>
 <20091118.104434.185425439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:55334 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758308AbZKRTAa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 14:00:30 -0500
In-Reply-To: <20091118.104434.185425439.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, November 18, 2009 10:45 AM
> To: Jeff Haran
> Cc: netdev@vger.kernel.org
> Subject: Re: NETLINK sockets dont honor SO_RCVLOWAT?
> 
> From: Jeff Haran <jharan@Brocade.COM>
> Date: Wed, 18 Nov 2009 10:41:06 -0800
> 
> > The operative term is "shall". The RFCs define "shall" to be
> > required behavior. I realize the RFCs do not dictate how Linux
> > works, but even the common English language usage of the word
> > "shall" conveys this meaning.
> 
> The low water mark can be seen as a hint, therefore we can
> apply the term "support" loosely here.
>
> And the errors are advisory, just like things like -EFAULT.
> 
> Look, I'm not going to add a feature flag or some callback just to
> handle this.
> 
> You have to know what kind of protocol you are working with, and
> therefore which socket options make any sense for it.

If the open source community doesn't want a fix for something that is obviously broken, that's fine. We fix a lot of broken kernel code here at Brocade. But at least now I know that I need not bother with submitting a patch. That will save everybody a lot of time.

Thanks,

Jeff Haran
Brocade Communications
