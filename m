From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Wed, 18 Mar 2009 00:24:33 +0800
Message-ID: <b6a2187b0903170924u72723220x4c0a717e3cfebf8d@mail.gmail.com>
References: <1237140665.24621.2.camel@johannes.local>
	 <1237143683.24621.7.camel@johannes.local>
	 <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <alpine.LFD.2.00.0903161250080.3082@localhost.localdomain>
	 <b6a2187b0903161655q15437156qc926c8db37d8ba4b@mail.gmail.com>
	 <20090317144802.GF3549@tuxdriver.com>
	 <20090317152801.GA6737@tuxdriver.com> <20090317153924.GA21061@elte.hu>
	 <20090317160527.GB6737@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f122.google.com ([209.85.221.122]:60476 "EHLO
	mail-qy0-f122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753754AbZCQQYh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 12:24:37 -0400
In-Reply-To: <20090317160527.GB6737@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2009 at 12:05 AM, John W. Linville <linville@tuxdriver.=
com>
> the reverts. =A0But if you think it is helpful:
> =A0 =A0 =A0 =A0http://bugzilla.kernel.org/attachment.cgi?id=3D20567&a=
ction=3Dview

I tried applying the above patch against the latest linux git
(18439c39e826191c0ef08c3a3271ce7ece46a860), but got a lot of rejects.
Is this supposed to be?


patch -p1 </tar/v2.6/revert-remove-ssid-knowledge-from-driver-series.pa=
tch
1 out of 1 hunk FAILED -- saving rejects to file
drivers/net/wireless/adm8211.h.rej
1 out of 2 hunks FAILED -- saving rejects to file
drivers/net/wireless/b43/main.c.rej
1 out of 2 hunks FAILED -- saving rejects to file
drivers/net/wireless/b43legacy/main.c.rej
1 out of 1 hunk FAILED -- saving rejects to file
drivers/net/wireless/iwlwifi/iwl-3945.h.rej
3 out of 4 hunks FAILED -- saving rejects to file
drivers/net/wireless/iwlwifi/iwl-agn.c.rej
1 out of 1 hunk FAILED -- saving rejects to file
drivers/net/wireless/iwlwifi/iwl-dev.h.rej
3 out of 5 hunks FAILED -- saving rejects to file
drivers/net/wireless/iwlwifi/iwl3945-base.c.rej
1 out of 3 hunks FAILED -- saving rejects to file include/net/mac80211.=
h.rej

Thanks,
Jeff.
