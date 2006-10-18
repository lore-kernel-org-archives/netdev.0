From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Wed, 18 Oct 2006 11:51:46 +0200
Message-ID: <200610181151.46506.dpc@asn.pl>
References: <200610151820.22867.dpc@asn.pl> <17717.40394.531846.695392@localhost.localdomain> <20061017.202544.74747614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: stephen@dino.dnsalias.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:49364 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S1751084AbWJRJvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 05:51:54 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061017.202544.74747614.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 18 October 2006 05:25, David Miller wrote:
> From: stephen@dino.dnsalias.com (Stephen J. Bevan)
> Date: Tue, 17 Oct 2006 20:21:46 -0700
> 
> > * You write "frames will be delivered in order, so on the other side
> >   IV can be always in sync."
> 
> In fact, in addition to your comments, Linux can reorder packets
> locally within the system even within traffic for the same link.
>
> Any technology which absolutely requires in order packet delivery
> isn't going to work very well.

I've tried to put ccrypt handlers as close to hardware xmit and recv as 
possible so local reorder doesn't matter. Medium doesn't reorder frames and 
switches, bridges shouldn't do that neither (but as Stephen J. Bevan said 
this may not be always true).
