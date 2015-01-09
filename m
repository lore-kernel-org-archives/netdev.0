From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] net: wireless: rtlwifi: btcoexist: halbtc8821a2ant:
 Remove some unused functions
Date: Fri, 9 Jan 2015 18:23:40 +0100
Message-ID: <CAKXHbyM2JXBgknL+WqVqkLcPMfWHHF4D8j44Cqenj76Gvd8PXQ@mail.gmail.com>
References: <1420230361-1862-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<871tn7zsie.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:41468 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758123AbbAIRXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:23:42 -0500
Received: by mail-ig0-f176.google.com with SMTP id a13so2671245igq.3
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:23:42 -0800 (PST)
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com. [209.85.223.173])
        by mx.google.com with ESMTPSA id l14sm4077530ioi.31.2015.01.09.09.23.41
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 09:23:41 -0800 (PST)
Received: by mail-ie0-f173.google.com with SMTP id y20so16103230ier.4
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:23:41 -0800 (PST)
In-Reply-To: <871tn7zsie.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All

Yes I use sed as Julian said. I have it as part of my git send-email
script, until a few week ago, it was enough that I removed the
"drivers/" and changed all "/" to ": "
I have now been expanded my sed pipe a lot (tell me if anyone is interested).
But a real script to do this would have been very good I think!

It may be, there was some mail problems during the holiday season :-(
There is not a total consensus on how patcher will was designed.
I have previously received complaints that I made for large patches of
too many files.
Have since tried to make small patches, and it also fit better to have
more specific paths in the subject line.

But I'll try to gather all in one patchset instead this weekend.


Kind regards
Rickard Strandqvist



2015-01-06 19:14 GMT+01:00 Kalle Valo <kvalo@codeaurora.org>:
> Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> writes:
>
>> Removes some functions that are not used anywhere:
>> ex_halbtc8821a2ant_periodical() ex_halbtc8821a2ant_halt_notify()
>> ex_halbtc8821a2ant_bt_info_notify()
>> ex_halbtc8821a2ant_special_packet_notify()
>> ex_halbtc8821a2ant_connect_notify() ex_halbtc8821a2ant_scan_notify()
>> ex_halbtc8821a2ant_lps_notify() ex_halbtc8821a2ant_ips_notify()
>> ex_halbtc8821a2ant_display_coex_info() ex_halbtc8821a2ant_init_coex_dm()
>> ex_halbtc8821a2ant_init_hwconfig()
>>
>> This was partially found by using a static code analysis program called cppcheck.
>>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
>
> Rickard, I have dropped all your patches because I lost track which I
> should apply and which not and I do not want to waste half an hour
> figuring out. Please resend the ones which are still valid.
>
> And to make it easier for everyone please group these wireless-drivers
> cleanup patches into a larger patchset (like 10-15 patches max per
> patchset). That way it's a lot easier for me tomanage them. Sending one
> patch a day is not recommended, especially when we are talking trivial
> cleanup patches like this.
>
> --
> Kalle Valo
