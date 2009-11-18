From: Jeff Haran <jharan@Brocade.COM>
Subject: RE: NETLINK sockets dont honor SO_RCVLOWAT?
Date: Wed, 18 Nov 2009 10:22:54 -0800
Message-ID: <D67825C5985D0647BE40A5F5B0B70D1106E9C568F1@HQ-EXCH-7.corp.brocade.com>
References: <D67825C5985D0647BE40A5F5B0B70D1106E9C56894@HQ-EXCH-7.corp.brocade.com>
 <20091117.231706.125598146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:13812 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932254AbZKRSWu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 13:22:50 -0500
In-Reply-To: <20091117.231706.125598146.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Tuesday, November 17, 2009 11:17 PM
> To: Jeff Haran
> Cc: netdev@vger.kernel.org
> Subject: Re: NETLINK sockets dont honor SO_RCVLOWAT?
> 
> From: Jeff Haran <jharan@Brocade.COM>
> Date: Tue, 17 Nov 2009 17:54:59 -0800
> 
> > Am I correct in my observation that the SO_RCVLOWAT socket option is
> > not honored when one calls readv() on a PF_NETLINK socket?
> 
> That's correct.
> 
> SO_RCVLOWAT is only available on stream based sockets such as TCP and
> UNIX.
> 

David,

Thanks for the prompt response.

So is this a bug or a feature?

When I call setsockopt() to set this option on a NETLINK socket, setsockopt() appears to return 0 to indicate success. If it's not going to be supported, shouldn't setsockopt() return -1 with ENOPROTOOPT in errno in this case?

This is the behavior I would assume from reading the setsockopt() man page.

I am running this on a 2.6.14 kernel, so perhaps this had been corrected in later versions.

Jeff Haran
Brocade Communications
