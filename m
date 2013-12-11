From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Wed, 11 Dec 2013 21:26:15 +0000
Message-ID: <1386797175.1516.272.camel@bwh-desktop.uk.level5networks.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <201312101852.17030@pali> <1386703339.30202.19.camel@dcbw.foobar.com>
	 <201312102031.23797@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, Kalle Valo <kvalo@adurom.com>,
	"Luciano Coelho" <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <freemangordon@abv.bg>,
	<aaro.koskinen@iki.fi>, <pavel@ucw.cz>, <sre@ring0.de>,
	<joni.lapilainen@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201312102031.23797@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-10 at 20:31 +0100, Pali Roh=C3=A1r wrote:
[...]
> So, if you like this idea, can you help me how to write udev rule=20
> which will run my own program (it print mac address) and send mac=20
> address when driver ask for mac address in request_firmware?=20
> Problem is that default udev rule for firmware trying to load data=20
> from /lib/firmware/... but in this case mac address first must be=20
> read from special location and converted to correct format.

Unfortunately, udev no longer supports firmware loading during module
loading (unless that was fixed - I don't think it has been).  Loading
firmware *files* still works because the kernel can read those directly
rather than requesting them from udev.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
