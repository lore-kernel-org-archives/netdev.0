From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SIP proxying: siproxd vs. Netfilter SIP nat
Date: Mon, 30 Nov 2009 11:55:51 -0600 (CST)
Message-ID: <alpine.DEB.2.00.0911301154210.17037@router.home>
References: <alpine.DEB.2.00.0911301104520.16713@router.home> <4B13FF05.5060005@trash.net> <alpine.DEB.2.00.0911301123110.17037@router.home> <4B140129.2050907@trash.net> <alpine.DEB.2.00.0911301133280.17037@router.home> <4B140508.1090802@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christian Hentschel <chentschel@arnet.com.ar>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi129.sbcis.sbc.com ([207.115.36.143]:47247 "EHLO
	nlpi129.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbZK3Rzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:55:48 -0500
In-Reply-To: <4B140508.1090802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Nov 2009, Patrick McHardy wrote:

> No, this is deliberate since it diverges from the behaviour of other
> helpers. Usually they only allow to create RELATED connections between
> the two hosts communicating. If you set either of these module options
> to zero, they will allow completely foreign addresses to establish
> connections when those addresses appear in the SDP payload. You should
> usually use additional filters to f.i. only allow source addresses of
> your registrar:
>
> iptables -A FORWARD -m state --state RELATED \
> 		    -m helper --helper "sip" \
> 		    -s registrar-network/X -j ACCEPT

Please put documentation with all these tricks somewhere where people
looking for SIP NAT can find it. I see multiple threads where people have
struggled with setting up SIP proxying and have failed.

