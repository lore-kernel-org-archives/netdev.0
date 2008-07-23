From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: Invalid truesize messages since 2.6.25
Date: Wed, 23 Jul 2008 09:55:35 +0200
Message-ID: <BAY103-DAV8A660F654389B540695E2B2840@phx.gbl>
References: <3C59DB883F7B0B4D8096010D45ACCD13C73AFA@exch.facton.local> <20080722114311.GQ10471@solarflare.com> <3C59DB883F7B0B4D8096010D45ACCD13C73B02@exch.facton.local> <8a75de9b0807221020s6831bebahafa4de57e93d3098@mail.gmail.com>
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>
To: "Markus Werner" <markiwer@googlemail.com>,
	"Beschorner Daniel" <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s25.bay0.hotmail.com ([65.54.246.97]:11032 "EHLO
	bay0-omc1-s25.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750793AbYGWH44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 03:56:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Werner wrote:

> 2008/7/22 Beschorner Daniel <Daniel.Beschorner@facton.com>:
> >>> Since 2.6.25 we rarely see these messages:
> >>>
> >>> SKB BUG: Invalid truesize (408) len=198, sizeof(sk_buff)=216
>
> Same problem here.

I haven't seen the problem after 7 days uptime with
2.6.26
With 2.6.25.x was very rare. My boxes are ipsec gateways
driven by openswan, squid and netfilter.
Network driver is 3c59x were the problem happened.

I was getting the warning both on system with and
without sfq/htb

On boxes without ipsec/netfilter (sendmail server)
I did never get this message.

> > The unusal part special to this server may be:
> > Bandwidth management via htb & sfq, CONFIG_IP_MULTIPLE_TABLES for
source
> > IP routing

Same for me. I do policy routing based on fwmark.
Just to be clear: I get this message with ipsec/
netfilter/policy routing and with/without sfq/htb


