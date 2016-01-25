From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] brcmfmac: sdio: Increase the default timeouts a bit
Date: Tue, 26 Jan 2016 10:41:37 +1100
Message-ID: <CAGRGNgVftXxnq06MOHKNVzVjvCkwCM8Bc+Sfs4NoOQR=sfYP-g@mail.gmail.com>
References: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
 <CAGRGNgXWE=b52Mcy8NsKBZS_4gz-TUiuFipjsuTZh1xjja=uUg@mail.gmail.com> <56A641CC.6020500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	Kalle Valo <kvalo@codeaurora.org>,
	Paul Stewart <pstew@chromium.org>,
	Doug Anderson <dianders@chromium.org>,
	linux-rockchip@lists.infradead.org,
	Arend van Spriel <arend@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	brcm80211-dev-list@broadcom.com,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hante Meuleman <meuleman@broadcom.com>,
	Brett Rudley <brudley@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Arend van Spriel <aspriel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36047 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933570AbcAYXl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 18:41:57 -0500
In-Reply-To: <56A641CC.6020500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arend,

On Tue, Jan 26, 2016 at 2:39 AM, Arend van Spriel <aspriel@gmail.com> wrote:
> On 25-01-16 12:06, Julian Calaby wrote:
>> Hi Sjoerd,
>>
>> On Mon, Jan 25, 2016 at 9:47 PM, Sjoerd Simons
>> <sjoerd.simons@collabora.co.uk> wrote:
>>> On a Radxa Rock2 board with a Ampak AP6335 (Broadcom 4339 core) it seems
>>> the card responds very quickly most of the time, unfortunately during
>>> initialisation it sometimes seems to take just a bit over 2 seconds to
>>> respond.
>>>
>>> This results intialization failing with message like:
>>>   brcmf_c_preinit_dcmds: Retreiving cur_etheraddr failed, -52
>>>   brcmf_bus_start: failed: -52
>>>   brcmf_sdio_firmware_callback: dongle is not responding
>>>
>>> Increasing the timeout to allow for a bit more headroom allows the
>>> card to initialize reliably.
>>>
>>> A quick search online after diagnosing/fixing this showed that Google
>>> has a similar patch in their ChromeOS tree, so this doesn't seem
>>> specific to the board I'm using.
>>>
>>> Signed-off-by: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
>>
>> Looks sane to me.
>>
>> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
>
> Not really a cleanup patch :-p , but thanks for the review.

I'm trying to review any "small" patch from (relatively) new people.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
