From: David Lv <davidlv.linux@gmail.com>
Subject: Re: [PATCH] via-velocity: fix the WOL bug on 1000M full duplex forced mode
Date: Fri, 17 Dec 2010 16:25:55 +0800
Message-ID: <AANLkTimVVV76MRn1H8U6nA4V-A7a6WpR2eWgc+mCHjRv@mail.gmail.com>
References: <AANLkTi=-MRrH1nCcbzqUMoP1sd=7opNGAz7KwmdoMmjA@mail.gmail.com>
	<4D0A5BBF.7000400@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Jan Ceuleers <jan.ceuleers@computer.org>, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:57640 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab0LQIZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 03:25:56 -0500
Received: by fxm18 with SMTP id 18so404723fxm.2
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 00:25:55 -0800 (PST)
In-Reply-To: <4D0A5BBF.7000400@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am very Sorry to cause you some trouble.
There are some differences with this version and previous version.

} else if (SPD_DPX_1000_FULL != pInfo->hw.sOpts.spd_dpx) {
+		if (SPD_DPX_AUTO == pInfo->hw.sOpts.spd_dpx) {

changed to

} else if (SPD_DPX_1000_FULL != vptr->options.spd_dpx) {
+		if (SPD_DPX_AUTO == vptr->options.spd_dpx) {




2010/12/17 Jan Ceuleers <jan.ceuleers@computer.org>:
> On 16/12/10 10:33, David Lv wrote:
>>
>> This patch isn't based on the first patch of the sleep speed 10M.
>> The VIA velocity card can't be waken up by WOL tool on 1000M full
>> duplex forced mode.
>> This patch fixes the bug.
>> Thanks!
>
> This patch is whitespace-damaged. Your previous version (14 December)
> wasn't. Why did you resend? Is there a difference?
>
> Thx, Jan
>
