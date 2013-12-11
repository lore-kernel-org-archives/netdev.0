From: Ivajlo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Subject: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting permanent
 mac address
Date: Thu, 12 Dec 2013 00:36:30 +0200
Message-ID: <52A8E8EE.7050001@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>		 <201312101814.35112@pali> <1386697762.30202.6.camel@dcbw.foobar.com>		 <201312101852.17030@pali>	 <1386796654.1516.268.camel@bwh-desktop.uk.level5networks.com>	 <52A8DA9A.50501@gmail.com> <1386800135.1516.296.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?UGFsaSBSb2jDoXI=?= <pali.rohar@gmail.com>,
	Dan Williams <dcbw@redhat.com>, Kalle Valo <kvalo@adurom.com>,
	Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386800135.1516.296.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 12.12.2013 00:15, Ben Hutchings wrote:
> 2. NVRAM reading is done by a tiny driver that is loaded based on the
> platform name and updates the DT node in memory.  (But I don't know how
> wl1251 should decide to defer probing if it's probed before that other
> driver.)
>
> Ben.
>

Maybe a "hwmac" property with a value of XX:XX:XX:XX:XX:XX (or some 
other invalid value) set in DT could be used to tell the driver to defer 
until that value changes to something sane?

Ivo
