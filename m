From: "Adam Kropelin" <akropel1@rochester.rr.com>
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 3 Feb 2007 23:44:07 -0500
Message-ID: <09ba01c74817$1ae12980$84163e05@kroptech.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org> <20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com> <m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com> <089b01c747be$0ca22620$84163e05@kroptech.com> <45C4F3F1.6060500@intel.com> <m1ejp70wu0.fsf@ebiederm.dsl.xmission.com> <098001c747e9$d8931b60$84163e05@kroptech.com> <m1ps8qzpte.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: "Auke Kok" <auke-jan.h.kok@intel.com>,
	"Adrian Bunk" <bunk@stusta.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, <alan@lxorguk.ukuu.org.uk>,
	"Allen Parker" <parker@isohunt.com>, <jesse.brandeburg@intel.com>,
	<gregkh@suse.de>, <linux-pci@atrey.karlin.mff.cuni.cz>,
	<netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-04.nyroc.rr.com ([24.24.2.58]:44137 "EHLO
	ms-smtp-04.nyroc.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbXBDEpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 23:45:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> "Adam Kropelin" <akropel1@rochester.rr.com> writes:
>
>>> Can I get the corresponding lspci -xxx output.  I suspect the BIOS
>>> did not program the hypertransport MSI mapping capabilities
>>> correctly. All it has to do is set the enable but still,
>>> occasionally BIOS writers miss the most amazing things.
>>
>> Here you go. This is from 2.6.20-rc7.
>
> Thanks.  Conclusion.  I could not find bit 16 (the enable bit) set in
> any of your hypertransport msi mapping capabilities.
>
> So MSI interrupts won't work until someone enables your chipset
> to transform them into hypertransport interrupts.

Naive question... Can the pci layer (or e1000) detect that MSI is not 
enabled in the hardware and avoid using it in that case? With the number 
of MSI problems showing up it seems risky to assume it's usable on any 
given platform without some sort of sanity check.

--Adam

