From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: Linux 2.6.24.1 - kernel does not boot; IRQ trouble?
Date: Fri, 22 Feb 2008 09:41:54 +0000 (GMT)
Message-ID: <769836.91421.qm@web52909.mail.re2.yahoo.com>
References: <3ae72650802220111s11e68f1ft149d7832e9bebbd6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <3ae72650802220111s11e68f1ft149d7832e9bebbd6@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- Kay Sievers <kay.sievers@vrfy.org> wrote:
> Greg,
> it seems that:
>   arch/x86/pci/legacy.c :: pci_legacy_init()
> 
> tries to create already created "bridge" symlinks in 2.6.24. So we
> discover the same devices twice? Can this be a reason for the hang?

No, it can't be because it's *not* hanging in this configuration :-). It hangs when I *don't* add
the acpi=noirq option, whereas here it's just adding noise to the dmesg log. (I'm guessing Linux
doesn't call pci_legacy_init() when ACPI takes charge of the IRQs.)

Cheers,
Chris



      __________________________________________________________
Sent from Yahoo! Mail.
A Smarter Inbox. http://uk.docs.yahoo.com/nowyoucan.html
