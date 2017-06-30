From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Fri, 30 Jun 2017 23:35:41 +0200
Message-ID: <a956b366-95d9-e876-4dba-149d2987633a@broadcom.com>
References: <0fd90416-f33c-a6be-14fd-5e964583e9cb@broadcom.com>
 <20170515231339.GF17314@wotan.suse.de>
 <0c43c825-df2a-b427-4b67-f17fd644667f@broadcom.com>
 <20170623215319.GU21846@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Li@suse.de, Yi <yi1.li@linux.intel.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Pavel Machek <pavel@ucw.cz>, Daniel Wagner <wagi@monom.org>,
        Tom Gundersen <teg@jklm.no>,
        =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Takashi Iwai <tiwai@suse.de>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38842 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753074AbdF3Vfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 17:35:44 -0400
Received: by mail-wm0-f50.google.com with SMTP id f67so4296890wmh.1
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 14:35:44 -0700 (PDT)
In-Reply-To: <20170623215319.GU21846@wotan.suse.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 23-06-17 23:53, Luis R. Rodriguez wrote:
> On Tue, May 16, 2017 at 10:41:08AM +0200, Arend Van Spriel wrote:
>> On 16-5-2017 1:13, Luis R. Rodriguez wrote:
>>> Since no upstream delta is needed for firmwared I'd like to first encourage
>>> evaluating the above. While distributions don't carry it yet that may be seen as
>>> an issue but since what we are looking for are corner cases, only folks needing
>>> to deploy a specific solution would need it or a custom proprietary solution.
>>
>> Ok. I will go try and run firmwared in OpenWrt on a router platform.
>> Have to steal one from a colleague :-p Will study firmwared.
> 
> Arend, curious how this effort goes. Its important to me as we know then that
> if this works its a good approach to recommend moving forward which should also
> prove less complex than that soup we had with the custom fallback stuff.

Hi Luis,

So I looked at firmwared and we basically need to extend it. For our
router platform we need to obtain nvram calibration data from an MTD
partition which contains the raw data, ie. no file-system on it. So
firmwared would need some sort of configuration to map a particular
firmware file to some action obtaining the data like kicking off some
mtd-utils in my case.

Regards,
Arend
