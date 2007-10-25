From: Tom Prince <tom.prince@ualberta.net>
Subject: Fried r8169.
Date: Thu, 25 Oct 2007 11:44:42 -0400
Message-ID: <20071025154438.GA2673@hermes.priv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.185]:33750 "EHLO
	rn-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756882AbXJYPmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 11:42:02 -0400
Received: by rn-out-0102.google.com with SMTP id s46so542520rnb
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 08:42:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 24, 2007 at 10:11:23PM -0600, Tom Prince wrote:
While testing Linux v2.6.24-rc1, I noticed that my onboard r8169 had
disappeared, and the it remained gone when I rebooted to v2.6.23 and v2.6.22,
where it had previously worked.
 
I have no idea where to begin debugging (or even reproducing) this, but am
quite willing to provide whatever additional details are requested.

I am running x86_64 ASUS Z92T laptop (an OEM version of the A6T).

I have posted dmesg/lspci/config from v2.6.23 (and soon v2.6.24) at 
 www.math.uwo.ca/~rprince5/r8169/

Also these appear to be the relevant log messages from when the device was
working. Unfortunately, I didn't have the foresight to save dmesg/lspci from
before the device disappeared.

kernel: r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
kernel: ACPI: PCI Interrupt Link [LNEA] enabled at IRQ 16
kernel: ACPI: PCI Interrupt 0000:01:00.0[A] -> Link [LNEA] -> GSI 16 (level, low) -> IRQ 16
kernel: PCI: Setting latency timer of device 0000:01:00.0 to 64
kernel: eth1: RTL8168b/8111b at 0xffffc200020e2000, 00:18:f3:87:0b:bb, XID 38000000 IRQ 16

  Tom

[PS Please CC me.]

