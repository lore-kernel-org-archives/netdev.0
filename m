From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] ipv6: don't accept multicast traffic with scop 0
Date: Mon, 11 Feb 2013 16:49:13 -0600
Message-ID: <1360622953.8633.36.camel@dcbw.foobar.com>
References: <20130210124851.GB18219@order.stressinduktion.org>
	 <20130211194835.GD23991@order.stressinduktion.org>
	 <20130211.145252.603354702530166412.davem@davemloft.net>
	 <1360621271.2701.20.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	erik.hugne@ericsson.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932777Ab3BKWtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2013 17:49:24 -0500
In-Reply-To: <1360621271.2701.20.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-11 at 22:21 +0000, Ben Hutchings wrote:
> On Mon, 2013-02-11 at 14:52 -0500, David Miller wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Mon, 11 Feb 2013 20:48:35 +0100
> > 
> > > On Sun, Feb 10, 2013 at 01:48:51PM +0100, Hannes Frederic Sowa wrote:
> > >> +	/*
> > >> +	 * RFC4291 2.7
> > >> +	 * Nodes must not originate a packet to a multicast address whose scop
> > >> +	 * field contains the reserved value 0; if such a packet is received, it
> > >> +	 * must be silently dropped.
> > > 
> > > Just nit-picking: The field is actually called scop without e, as pointed out
> > > by three erratas to RFC4291. :)
> > 
> > That's funny because I added the 'e' to your patches while applying
> > them, it just looks completely stupid to refer to this things as
> > 'scop'.
> 
> It seems to be a long Unix tradition to creat names with trailing silent
> vowels removed; this is hardly uniq.

You had to buy vowels from Pat back then, and people were stingy with
their hard-earned money.  And then if you got the vowel wrong it was no
longer your turn.  So understandably people were reluctant to use vowels
much.

Dan
