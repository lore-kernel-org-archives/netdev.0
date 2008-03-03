From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: Re: [BUG kernel 2.6.25-rc3 IPV6] ping6 -I eth0 ff02::1 causes system hang.
Date: Tue, 4 Mar 2008 07:06:06 +0900 (JST)
Message-ID: <25310501.7301204581966098.komurojun-mbn@nifty.com>
References: <20080302.212717.120106718.yoshfuji@linux-ipv6.org>
 <20071006132601.f944f461.komurojun@nifty.com>
	<20071014073658.d4352b8c.komurojun@nifty.com>
	<20080302210716.69727582.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pxy2nd.nifty.com ([202.248.175.14]:9342 "HELO pxy2nd.nifty.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751307AbYCCWMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 17:12:47 -0500
In-Reply-To: <20080302.212717.120106718.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

CONFIG_IPV6=y
but other IPV6 option is all not set.
in my configuration(.config)


>It would be great if you have chance to bisect it...

I don't have enough time on week-days ...


Best Regards
Komuro


>
>Switch to netdev.
>
>In article <20080302210716.69727582.komurojun-mbn@nifty.com> (at Sun, 2 Mar 2
008 21:07:16 +0900), Komuro <komurojun-mbn@nifty.com> says:
>
>> On kernel 2.6.25-rc3, IPV6 multicast ping causes system hang
>> after sending several multicast ping packet.
>> 
>> >ping6 -I eth0 ff02::1 
>> 
>> This problem does not happen on kernel 2.6.24.
>> (does not depend on NIC)
>
>Hmm, I've never seen this on our testlab.  Anyone else?
>It would be great if you have chance to bisect it...
>
>--yoshfuji

