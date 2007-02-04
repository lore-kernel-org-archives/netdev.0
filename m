From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 03 Feb 2007 18:14:53 -0700
Message-ID: <m1ps8qzpte.fsf@ebiederm.dsl.xmission.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org>
	<20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com>
	<m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com>
	<089b01c747be$0ca22620$84163e05@kroptech.com>
	<45C4F3F1.6060500@intel.com>
	<m1ejp70wu0.fsf@ebiederm.dsl.xmission.com>
	<098001c747e9$d8931b60$84163e05@kroptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Auke Kok" <auke-jan.h.kok@intel.com>,
	"Adrian Bunk" <bunk@stusta.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, <alan@lxorguk.ukuu.org.uk>,
	"Allen Parker" <parker@isohunt.com>, <jesse.brandeburg@intel.com>,
	<gregkh@suse.de>, <linux-pci@atrey.karlin.mff.cuni.cz>,
	<netdev@vger.kernel.org>
To: "Adam Kropelin" <akropel1@rochester.rr.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751740AbXBDBQa@vger.kernel.org>
In-Reply-To: <098001c747e9$d8931b60$84163e05@kroptech.com> (Adam Kropelin's
	message of "Sat, 3 Feb 2007 18:20:08 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Adam Kropelin" <akropel1@rochester.rr.com> writes:

>> Can I get the corresponding lspci -xxx output.  I suspect the BIOS
>> did not program the hypertransport MSI mapping capabilities correctly.
>> All it has to do is set the enable but still, occasionally BIOS
>> writers miss the most amazing things.
>
> Here you go. This is from 2.6.20-rc7.

Thanks.  Conclusion.  I could not find bit 16 (the enable bit) set in any of
your hypertransport msi mapping capabilities.

So MSI interrupts won't work until someone enables your chipset
to transform them into hypertransport interrupts.

Ideally it is a BIOS issue, but it may be the kind of thing we can
fix up with quirks in the kernel.

Eric
