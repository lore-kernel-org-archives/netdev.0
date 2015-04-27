From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH 1/2] brcmfmac: prohibit ACPI power management for brcmfmac
 driver
Date: Mon, 27 Apr 2015 10:59:06 +0200
Message-ID: <553DFA5A.3090802@broadcom.com>
References: <553DC280.6080503@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
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
To: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <553DC280.6080503@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/27/15 07:00, Fu, Zhonghui wrote:
> ACPI will manage WiFi chip's power state during suspend/resume
> process on some tablet platforms(such as ASUS T100TA). This is
> not supported by brcmfmac driver now, and the context of WiFi
> chip will be damaged after resume. This patch disconnects the
> relationship between WiFi chip and it's ACPI companion, and
> prohibit ACPI PM for it.

Nice. However, ACPI may contain configuration data that brcmfmac needs 
on some platforms and Adrian Hunter is looking into this. So it is 
probably better to do this operation at the end of the probe before 
returning successful.

Regards,
Arend

> Signed-off-by: Zhonghui Fu<zhonghui.fu@linux.intel.com>
> ---
>   drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    5 +++++
>   1 files changed, 5 insertions(+), 0 deletions(-)
>
