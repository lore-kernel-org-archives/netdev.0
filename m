From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SIP proxying: siproxd vs. Netfilter SIP nat
Date: Mon, 30 Nov 2009 11:27:04 -0600 (CST)
Message-ID: <alpine.DEB.2.00.0911301123110.17037@router.home>
References: <alpine.DEB.2.00.0911301104520.16713@router.home> <4B13FF05.5060005@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christian Hentschel <chentschel@arnet.com.ar>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi157.sbcis.sbc.com ([207.115.36.171]:44039 "EHLO
	nlpi157.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbZK3R1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:27:03 -0500
In-Reply-To: <4B13FF05.5060005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Nov 2009, Patrick McHardy wrote:

> > http://people.netfilter.org/chentschel/docs/sip-conntrack-nat.html
>
> That documentation is horribly outdated.

Where do I find more recent documentation?

> > Isnt there a way to make the kernel module work in the same way siproxd
> > works and able to support multiple phones? Right now configuring SIP
> > connectivity is a messy thing that is not easily setup. Can we fix this?
>
> It should work fine with multiple phones, it even recognizes calls
> between two internal phones and makes the media stream go between
> them directly. Depending on how your registrar/proxy works, you might
> have to set one or both of these module options:

Loaded both sip modules without specifying any parameters. Resulted in one
way audio problems which is what I also get without the modules.

> sip_direct_signalling: when set to zero, allows incoming signalling
>  connections from other hosts than the registrar. Usually not needed.
>
> sip_direct_media: when set to zero, allows incoming media streams
>  from other hosts than the registrar. This one is often required,
>  some providers use server farms for handling the media streams,
>  some set up media streams to go directly between the endpoints.

Ok will try setting that parameter to zero.

