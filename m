From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting permanent
 mac address
Date: Thu, 12 Dec 2013 16:45:49 +0400
Message-ID: <52A9AFFD.1040408@cogentembedded.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>		 <201312101814.35112@pali> <1386697762.30202.6.camel@dcbw.foobar.com>		 <201312101852.17030@pali>	 <1386796654.1516.268.camel@bwh-desktop.uk.level5networks.com>	 <52A8DA9A.50501@gmail.com> <1386800135.1516.296.camel@bwh-desktop.uk.level5networks.com> <52A8E8EE.7050001@gmail.com>
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
To: Ivajlo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:39056 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476Ab3LLMps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 07:45:48 -0500
Received: by mail-la0-f45.google.com with SMTP id eh20so269465lab.32
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 04:45:47 -0800 (PST)
In-Reply-To: <52A8E8EE.7050001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-12-2013 2:36, Ivajlo Dimitrov wrote:

>> 2. NVRAM reading is done by a tiny driver that is loaded based on the
>> platform name and updates the DT node in memory.  (But I don't know how
>> wl1251 should decide to defer probing if it's probed before that other
>> driver.)

>> Ben.


> Maybe a "hwmac" property with a value of XX:XX:XX:XX:XX:XX (or some other
> invalid value) set in DT could be used to tell the driver to defer until that
> value changes to something sane?

    The standard property name for that is "local-mac-address". There's also 
non-standard "mac-address" variation.

> Ivo

WBR, Sergei
