From: Arend van Spriel <aspriel@gmail.com>
Subject: Re: [PATCH] brcmfmac: sdio: Increase the default timeouts a bit
Date: Tue, 26 Jan 2016 07:29:54 +0100
Message-ID: <56A71262.8000804@gmail.com>
References: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
 <CAGRGNgXWE=b52Mcy8NsKBZS_4gz-TUiuFipjsuTZh1xjja=uUg@mail.gmail.com>
 <56A641CC.6020500@gmail.com>
 <CAGRGNgVftXxnq06MOHKNVzVjvCkwCM8Bc+Sfs4NoOQR=sfYP-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
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
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36040 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbcAZG3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 01:29:52 -0500
In-Reply-To: <CAGRGNgVftXxnq06MOHKNVzVjvCkwCM8Bc+Sfs4NoOQR=sfYP-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-01-16 00:41, Julian Calaby wrote:
> Hi Arend,
> 
> On Tue, Jan 26, 2016 at 2:39 AM, Arend van Spriel <aspriel@gmail.com> wrote:
>> On 25-01-16 12:06, Julian Calaby wrote:
>>> Hi Sjoerd,
>>>
>>> On Mon, Jan 25, 2016 at 9:47 PM, Sjoerd Simons
>>> <sjoerd.simons@collabora.co.uk> wrote:
>>>> On a Radxa Rock2 board with a Ampak AP6335 (Broadcom 4339 core) it seems
>>>> the card responds very quickly most of the time, unfortunately during
>>>> initialisation it sometimes seems to take just a bit over 2 seconds to
>>>> respond.
>>>>
>>>> This results intialization failing with message like:
>>>>   brcmf_c_preinit_dcmds: Retreiving cur_etheraddr failed, -52
>>>>   brcmf_bus_start: failed: -52
>>>>   brcmf_sdio_firmware_callback: dongle is not responding
>>>>
>>>> Increasing the timeout to allow for a bit more headroom allows the
>>>> card to initialize reliably.
>>>>
>>>> A quick search online after diagnosing/fixing this showed that Google
>>>> has a similar patch in their ChromeOS tree, so this doesn't seem
>>>> specific to the board I'm using.
>>>>
>>>> Signed-off-by: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
>>>
>>> Looks sane to me.
>>>
>>> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
>>
>> Not really a cleanup patch :-p , but thanks for the review.
> 
> I'm trying to review any "small" patch from (relatively) new people.

And it is surely appreciated. Just read your reply in "cleanup patch
pile" thread and felt I had to make the stupid remark with just fun
intended.

Regards,
Arend
