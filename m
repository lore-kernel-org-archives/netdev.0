From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Wed, 18 Oct 2006 13:35:27 +0200
Message-ID: <200610181335.28278.dpc@asn.pl>
References: <17717.40394.531846.695392@localhost.localdomain> <200610181151.46506.dpc@asn.pl> <20061018.031629.88703132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: stephen@dino.dnsalias.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:43221 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S1030241AbWJRLfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 07:35:34 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061018.031629.88703132.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 18 October 2006 12:16, David Miller wrote:
> From: Dawid Ciezarkiewicz <dpc@asn.pl>
> Date: Wed, 18 Oct 2006 11:51:46 +0200
> 
> > I've tried to put ccrypt handlers as close to hardware xmit and recv as 
> > possible so local reorder doesn't matter. Medium doesn't reorder frames 
and 
> > switches, bridges shouldn't do that neither (but as Stephen J. Bevan said 
> > this may not be always true).
> 
> You can put it all the way in netif_receive_skb() and you still
> can see reordering of receive packets on an SMP system.

Thanks for pointing that out. As every frame reorder will cost "only" one real 
frame to by lost I need to investigate this issue and get more real testing 
in such environments.
