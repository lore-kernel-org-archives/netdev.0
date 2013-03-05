From: Shuah Khan <shuahkhan@gmail.com>
Subject: Re: [PATCH] net/wireless/brcm80211: remove PCI_BUS define from defs.h
 to fix warnings
Date: Mon, 4 Mar 2013 21:08:16 -0700
Message-ID: <CAKocOOOJRpaq-e=XX584e1JQDYq_N4q8rka0otZBWbdvzdLyuA@mail.gmail.com>
References: <1362445374.4591.28.camel@lorien2>
	<51354A28.3040607@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shuah.khan@hp.com, brudley@broadcom.com, arend@broadcom.com,
	frankyl@broadcom.com, linville@tuxdriver.com,
	seth.forshee@canonical.com, pieterpg@broadcom.com,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51354A28.3040607@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 4, 2013 at 6:28 PM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> On 03/04/2013 07:02 PM, Shuah Khan wrote:
>>
>> PCI_BUS defined in defs.h results in warnings from all brcm80211 source
>> files
>> including defs.h. This define is not used in brcm80211. Removing this
>> define
>> fixes the warning.
>>
>> In file included from
>> drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c:35:0:
>> drivers/net/wireless/brcm80211/include/defs.h:23:0: warning: "PCI_BUS"
>> redefined [enabled by default]
>> include/uapi/linux/pci.h:36:0: note: this is the location of the previous
>> definition
>>    CC [M]  drivers/net/wireless/b43legacy/dma.o
>>    CC [M]  drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.o
>>    CC [M]  drivers/net/wireless/b43legacy/pio.o
>> In file included from
>> drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c:29:0:
>> drivers/net/wireless/brcm80211/include/defs.h:23:0: warning: "PCI_BUS"
>> redefined [enabled by default]
>> include/uapi/linux/pci.h:36:0: note: this is the location of the previous
>> definition
>> In file included from
>> drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c:29:0:
>> drivers/net/wireless/brcm80211/include/defs.h:23:0: warning: "PCI_BUS"
>> redefined [enabled by default]
>> include/uapi/linux/pci.h:36:0: note: this is the location of the previous
>> definition
>
>
> Strange, I do not see PCI_BUS defined anywhere in the include/ branch in
> either 3.8 or 3.9. In addition, I don't get these warnings. What is
> different in your system?
>
> Larry

I am sorry. Please ignore this patch. I had a old commit for a change
I was working on
and I thought I undid the changes. My apologies for the noise.

-- Shuah
