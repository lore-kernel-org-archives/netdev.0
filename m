From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 08:16:09 -0700
Message-ID: <CA+55aFyC6tpgABYq-PXAiPVzi_jMs3sCiebvg6YKEkE=mcEFyA@mail.gmail.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com>
 <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
 <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com>
 <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
 <1345642009.15245.0.camel@deadeye.wl.decadent.org.uk> <CA+55aFzxhxjOeFSUUJ6XQGUmnaZf7QPSz611zmj2VziEDUB_sA@mail.gmail.com>
 <1345645499.15245.8.camel@deadeye.wl.decadent.org.uk> <CA+55aFxoWLad9vtfAzQ7qXWcspL92D5s5+MFJ-HfyH3LVqfpaA@mail.gmail.com>
 <CA+55aFzQDx78qBgDQyb6LuSyAyi_m=y8XjyRWf1J4kb0399U5w@mail.gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6FC0@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	David Miller <davem@davemloft.net>, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43835 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932467Ab2HVPQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 11:16:31 -0400
Received: by wgbdr13 with SMTP id dr13so957969wgb.1
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 08:16:30 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FC0@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 8:05 AM, David Laight <David.Laight@aculab.com> wrote:
>
> PCIe transfers are basically hdlc packets containing the address,
> command and any associated data. Unless they get bridged
> though some strange PCIe<->PCI<->PCIe system they are very
> unlikely to get broken up.

It's exactly the odd kind of "mix in a non-native PCIe bridge" setups
I'd worry about. But I guess that is pretty unlikely in any modern
machine (except for thunderbolt, and I think that's going to pass any
PCIe stuff through unchanged).

                  Linus
