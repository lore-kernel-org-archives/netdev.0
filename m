From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v3] brcmfmac: prohibit ACPI power management for brcmfmac driver
Date: Tue, 26 May 2015 13:46:50 +0300
Message-ID: <878ucb39b9.fsf@kamboji.qca.qualcomm.com>
References: <555016DC.804@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "brudley\@broadcom.com" <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	"meuleman\@broadcom.com" <meuleman@broadcom.com>,
	"pieterpg\@broadcom.com" <pieterpg@broadcom.com>,
	"hdegoede\@redhat.com" <hdegoede@redhat.com>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"brcm80211-dev-list\@broadcom.com" <brcm80211-dev-list@broadcom.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Fu\, Zhonghui" <zhonghui.fu@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <555016DC.804@linux.intel.com> (Zhonghui Fu's message of "Mon, 11
	May 2015 10:41:32 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Fu, Zhonghui" <zhonghui.fu@linux.intel.com> writes:

> ACPI will manage WiFi chip's power state during suspend/resume
> process on some tablet platforms(such as ASUS T100TA). This is
> not supported by brcmfmac driver now, and the context of WiFi
> chip will be damaged after resume. This patch informs ACPI not
> to manage WiFi chip's power state.
>
> Signed-off-by: Zhonghui Fu <zhonghui.fu@linux.intel.com>
> Acked-by: Arend van Spriel <arend@broadcom.com>

Thanks, applied to wireless-drivers-next.git.

-- 
Kalle Valo
