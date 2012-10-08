From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skge: Add DMA mask quirk for Marvell 88E8001 on ASUS
 P5NSLI motherboard
Date: Mon, 8 Oct 2012 09:55:17 -0700
Message-ID: <20121008095517.58f86ccc@nehalam.linuxnetplumber.net>
References: <1349715275-12730-1-git-send-email-jan.ceuleers@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Graham Gower <graham.gower@gmail.com>
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38702 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021Ab2JHQz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 12:55:57 -0400
In-Reply-To: <1349715275-12730-1-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  8 Oct 2012 18:54:35 +0200
Jan Ceuleers <jan.ceuleers@computer.org> wrote:

> From: Graham Gower <graham.gower@gmail.com>
> 
> Marvell 88E8001 on an ASUS P5NSLI motherboard is unable to send/receive
> packets on a system with >4gb ram unless a 32bit DMA mask is used.
> 
> This issue has been around for years and a fix was sent 3.5 years ago, but
> there was some debate as to whether it should instead be fixed as a PCI quirk.
> http://www.spinics.net/lists/netdev/msg88670.html
> 
> However, 18 months later a similar workaround was introduced for another
> chipset exhibiting the same problem.
> http://www.spinics.net/lists/netdev/msg142287.html
> 
> Signed-off-by: Graham Gower <graham.gower@gmail.com>
> Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
