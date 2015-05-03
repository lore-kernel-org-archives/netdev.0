From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: Re: [PATCH 1/2] brcmfmac: prohibit ACPI power management for brcmfmac
 driver
Date: Sun, 03 May 2015 23:30:55 +0800
Message-ID: <55463F2F.2050505@linux.intel.com>
References: <553DC280.6080503@linux.intel.com> <553DFA5A.3090802@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "brudley@broadcom.com" <brudley@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	"meuleman@broadcom.com" <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"pieterpg@broadcom.com" <pieterpg@broadcom.com>,
	"hdegoede@redhat.com" <hdegoede@redhat.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"brcm80211-dev-list@broadcom.com" <brcm80211-dev-list@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Adrian Hunter <adrian.hunter@intel.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57786 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbbECPbB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 May 2015 11:31:01 -0400
In-Reply-To: <553DFA5A.3090802@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2015/4/27 16:59, Arend van Spriel wrote:
> On 04/27/15 07:00, Fu, Zhonghui wrote:
>> ACPI will manage WiFi chip's power state during suspend/resume
>> process on some tablet platforms(such as ASUS T100TA). This is
>> not supported by brcmfmac driver now, and the context of WiFi
>> chip will be damaged after resume. This patch disconnects the
>> relationship between WiFi chip and it's ACPI companion, and
>> prohibit ACPI PM for it.
>
> Nice. However, ACPI may contain configuration data that brcmfmac needs on some platforms and Adrian Hunter is looking into this. So it is probably better to do this operation at the end of the probe before returning successful.
Your comment is right. I introduced another implementation in new patch - "[PATCH v2] brcmfmac: prohibit ACPI power management for brcmfmac driver".


Thanks,
Zhonghui
>
> Regards,
> Arend
>
>> Signed-off-by: Zhonghui Fu<zhonghui.fu@linux.intel.com>
>> ---
>>   drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    5 +++++
>>   1 files changed, 5 insertions(+), 0 deletions(-)
>>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
