From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: rt2x00: Kconfig symbols RALINK_RT288X and RALINK_RT305X
Date: Wed, 13 Mar 2013 11:35:31 +0100
Message-ID: <CAOiHx=keYYoCGgHfrSKXOHQQvG1mrt60ems3dcXki1K06MHg2g@mail.gmail.com>
References: <1363165170.3137.182.camel@x61.thuisdomein> <CAOiHx=n4a26z=PS02E2KjD2Y3Pp0P0x-5Ns6WRc-WScNF=EO_Q@mail.gmail.com>
 <1363169039.3137.186.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Crispin <blogic@openwrt.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nanl.de ([217.115.11.12]:52734 "EHLO mail.nanl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027Ab3CMKgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 06:36:25 -0400
In-Reply-To: <1363169039.3137.186.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 March 2013 11:03, Paul Bolle <pebolle@tiscali.nl> wrote:
> On Wed, 2013-03-13 at 10:51 +0100, Jonas Gorski wrote:
>> The actual accepted Kconfig symbol names are different though, so they
>> should be changed in rt2x00 to match them (SOC_RT288X and SOC_RT305X).
>
> Thanks. Note that I could not find an actual Kconfig symbol SOC_RT288X!

Ah, yes, the inital submission only included RT305X support, not
RT288X (and neither of the newer chips). These will come later.

> Anyhow, I guess somebody has the (trivial) patch to convert
> RALINK_RT...X and CONFIG_RALINK_RT...X to their SOC_* equivalents queued
> for inclusion in v3.9-rcX. Is that correct?

Yes, that should be everything. John Crispin, anything missing from that?


Jonas
