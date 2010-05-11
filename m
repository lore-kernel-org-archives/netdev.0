From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: e1000e fails probe
Date: Mon, 10 May 2010 18:33:56 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A90010D1DE754@orsmsx509.amr.corp.intel.com>
References: <20100510185018.3478bcae@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Pete Zaitcev <zaitcev@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37020 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751750Ab0EKBeC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:34:02 -0400
In-Reply-To: <20100510185018.3478bcae@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, May 10, 2010 5:50 PM, Pete Zaitcev wrote:
> Dear All:
> 
> I have a box where e1000e would refuse to probe the onboard interface
> with the following in dmesg:
> 
> e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
> e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
> e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> e1000e 0000:00:19.0: setting latency timer to 64
> e1000e 0000:00:19.0: irq 34 for MSI/MSI-X
> 0000:00:19.0: 0000:00:19.0: MDI Error
> e1000e 0000:00:19.0: PCI INT A disabled
> e1000e: probe of 0000:00:19.0 failed with error -2
> 
> The "MDI Error" seems to indicate a hardware failure, so I paid it no
> mind until I noticed that RHEL 5 works. So, I diffed the drivers
> between Linus' 2.6.34-rc5 and RHEL's 2.6.18-180.el5, with the
> following 
> minimal patch working for me:

Hi Pete,

Sorry you are having problems with e1000e.  You didn't mention which LOM device was on this system - is the PCI device id 0x10ea, 0x10eb, 0x10ef or 0x10f0?

What BIOS version is on the system?

Would you be able to try a patch that is already in DaveM's net-next-2.6 tree?  If so, it is http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=627c8a041f7aaaea93c766f69bd61d952a277586

Thanks,
Bruce.
