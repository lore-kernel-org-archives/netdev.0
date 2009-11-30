From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SIP proxying: siproxd vs. Netfilter SIP nat
Date: Mon, 30 Nov 2009 11:35:59 -0600 (CST)
Message-ID: <alpine.DEB.2.00.0911301133280.17037@router.home>
References: <alpine.DEB.2.00.0911301104520.16713@router.home> <4B13FF05.5060005@trash.net> <alpine.DEB.2.00.0911301123110.17037@router.home> <4B140129.2050907@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christian Hentschel <chentschel@arnet.com.ar>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi129.sbcis.sbc.com ([207.115.36.143]:41406 "EHLO
	nlpi129.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbZK3Rf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:35:56 -0500
In-Reply-To: <4B140129.2050907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Nov 2009, Patrick McHardy wrote:

> > Where do I find more recent documentation?
>
> Below :)

I found http://lwn.net/Articles/271597/ which mentions that those two
values may be set too strictly. Can they default to zero?

> You of course also need to accept the packets marked RELATED by
> the helper. If this is missing it might result in one-way audio.

Firewall is configured to accept all udp traffic. Will that do it?

The "helper" is the conntrack module?

