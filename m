From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Wed, 11 Dec 2013 22:15:35 +0000
Message-ID: <1386800135.1516.296.camel@bwh-desktop.uk.level5networks.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
		 <201312101814.35112@pali> <1386697762.30202.6.camel@dcbw.foobar.com>
		 <201312101852.17030@pali>
	 <1386796654.1516.268.camel@bwh-desktop.uk.level5networks.com>
	 <52A8DA9A.50501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
	Dan Williams <dcbw@redhat.com>, Kalle Valo <kvalo@adurom.com>,
	Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <freemangordon@abv.bg>,
	<aaro.koskinen@iki.fi>, <pavel@ucw.cz>, <sre@ring0.de>,
	<joni.lapilainen@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: Ivajlo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22828 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab3LKWPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 17:15:41 -0500
In-Reply-To: <52A8DA9A.50501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-11 at 23:35 +0200, Ivajlo Dimitrov wrote:
> On 11.12.2013 23:17, Ben Hutchings wrote:
> > I think that's an even worse idea.  This is not firmware and it already
> > exists in separate storage.
> >
> > I think that rx51_init_wl1251() in
> > arch/arm/mach-omap2/board-rx51-peripherals.c should either copy the MAC
> > address out of NVRAM, or if it's too early to do that, then schedule a
> > function to run later and only then set up wl1251 platform data.
> >
> > Ben.
> >
> 
> And how will that work with DT when board files will be in the history?

1. Boot loader reads the MAC address from NVRAM and puts it in the DT
node.
or
2. NVRAM reading is done by a tiny driver that is loaded based on the
platform name and updates the DT node in memory.  (But I don't know how
wl1251 should decide to defer probing if it's probed before that other
driver.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
