From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [announce] new rt2800 drivers for Ralink wireless & project tree
Date: Tue, 3 Nov 2009 22:00:03 +0100
Message-ID: <200911032200.04516.IvDoorn@gmail.com>
References: <200911031951.05235.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>,
	Luis Correia <luis.f.correia@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ingo Molnar <mingo@elte.hu>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Miller <davem@davemloft.net>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754407AbZKCVAH@vger.kernel.org>
In-Reply-To: <200911031951.05235.bzolnier@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 November 2009, Bartlomiej Zolnierkiewicz wrote:
> 
> Hi,
> 
> The following patch series (against wireless-next) addresses issues raised
> during code review and subsequently rejected by rt2x00/wireless/networking
> maintainers.

Really stop reading only the half of emails, try reading it entirely (or at least don't
stop at the second word in a sentence). It really starts the bug me to repeat
myself over and over again because you refuse to read.

Your comments during code review were ACCEPTED with the only remark that
it shouldn't be done right here and now.

[snip]

> The rewrite was quite conservative and there is still a room for improvement
> but it should serve as a good starting base for all future work on rt2800
> drivers, and there is a lot to do there (both drivers are still practically
> non-functional).

Hence the reason I can use my rt2800usb device as long as I don't connect to
a 11n AP. But since everybody in the world has 11n devices, the rt2800usb device
is not capable of doing anything...

> Comments and patches are welcomed.
> 
> 
> The following changes since commit fa867e7355a1bdcd9bf7d55ebe9296f5b9c4028a:
>   Juuso Oikarinen (1):
>         wl1271: Generalize command response reading
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/bart/misc.git rt2800
> 
> Bartlomiej Zolnierkiewicz (40):
>       rt2800usb: fix rt2800usb_rfcsr_read()
>       rt2800pci: fix crypto in TX frame
>       rt2800pci: fix comment about register access
>       rt2800pci: fix comment about IV/EIV fields
>       rt2x00: fix rt2x00usb_register_read() comment
>       rt2800usb: use rt2x00usb_register_multiwrite() to set key entries
[.. snip..]
>       rt2800usb: fix comments in rt2800usb.h
>       rt2800usb: add RXINFO_DESC_SIZE definition
[..snip..]
>       rt2800: fix comments in rt2800.h
[..snip..]
>       rt2x00: remove needless ifdefs from rt2x00leds.h

These 10 patches look sane enough. Please send them as patch series
to linux-wireless.

>       rt2x00: add support for different chipset interfaces

Not needed, you can determine exactly what chipset you have
by looking at the other fields. So extending the structure to
repeat the same information isn't needed.

>       MAINTAINERS: add rt2800 entry

I see you decided to take over the maintainership?
Doesn't that need the current maintainer to move away, or was this part
of the "going over other peoples head" plan?

>       rt2800usb: add rt2800_register_[read,write]() wrappers
>       rt2800pci: add rt2800_register_[read,write]() wrappers
>       rt2800usb: add rt2800_register_multi[read,write]() wrappers
>       rt2800pci: add rt2800_register_multi[read,write]() wrappers
>       rt2800usb: add rt2800_regbusy_read() wrapper
>       rt2800pci: add rt2800_regbusy_read() wrapper
>       rt2800usb: add rt2800_bbp_[read,write]() wrappers
>       rt2800pci: add rt2800_bbp_[read,write]() wrappers
>       rt2800usb: add rt2800_rfcsr_[read,write]() wrappers
>       rt2800pci: add rt2800_rfcsr_[read,write]() wrappers
>       rt2800usb: add rt2800_rf_[read,write]() wrappers
>       rt2800pci: add rt2800_rf_[read,write]() wrappers
>       rt2800usb: add rt2800_mcu_request() wrapper
>       rt2800pci: add rt2800_mcu_request() wrapper
>       rt2x00: add driver private field to struct rt2x00_dev
>       rt2800usb: convert to use struct rt2800_ops methods
>       rt2800pci: convert to use struct rt2800_ops methods
>       rt2x00: fix rt2x00usb_register_multiwrite() arguments
>       rt2x00: fix rt2x00usb_regbusy_read() arguments
>       rt2x00: fix rt2x00pci_register_multi[read,write]() arguments
>       rt2800: add rt2800lib.h
>       rt2800: fix duplication in header files
>       rt2800: prepare for rt2800lib addition
>       rt2800: add rt2800lib (part one)
>       rt2800: add rt2800lib (part two)
>       rt2x00: move REGISTER_BUSY_* definitions to rt2x00.h
>       rt2800: add rt2800lib (part three)
>       rt2800: add rt2800lib (part four)

These are too much (and too big) patches for me to review at once, I'll look at
them later.

Ivo
