From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.23-rc2-mm1
Date: Thu, 09 Aug 2007 15:23:41 +0200
Message-ID: <46BB155D.8050501@googlemail.com>
References: <20070809015106.cd0bfc53.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:10198 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932783AbXHINYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 09:24:10 -0400
Received: by fk-out-0910.google.com with SMTP id z23so410057fkz
        for <netdev@vger.kernel.org>; Thu, 09 Aug 2007 06:24:09 -0700 (PDT)
In-Reply-To: <20070809015106.cd0bfc53.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton pisze:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc2/2.6.23-rc2-mm1/

I am experiencing some problems with 8139too

[   28.847004] 8139too 0000:02:0d.0: region #0 not a PIO resource, aborting
[   28.854722] Bad IO access at port 0 ()
[   28.859459] WARNING: at /home/devel/linux-mm/lib/iomap.c:44 bad_io_access()
[   28.867415]  [<c040536b>] show_trace_log_lvl+0x1a/0x30
[   28.873568]  [<c0405ff3>] show_trace+0x12/0x14
[   28.879015]  [<c0406128>] dump_stack+0x16/0x18
[   28.884451]  [<c052a904>] bad_io_access+0x58/0x5a
[   28.890129]  [<c052a927>] pci_iounmap+0x21/0x2b
[   28.895635]  [<c05b3746>] __rtl8139_cleanup_dev+0x75/0xc6
[   28.902037]  [<c05b42c4>] rtl8139_init_one+0x59b/0xa9f
[   28.908170]  [<c053e344>] pci_device_probe+0x44/0x5f
[   28.914116]  [<c05a7cd0>] driver_probe_device+0xa7/0x19a
[   28.920402]  [<c05a7f1a>] __driver_attach+0xa6/0xa8
[   28.926236]  [<c05a71d3>] bus_for_each_dev+0x43/0x61
[   28.932139]  [<c05a7b51>] driver_attach+0x19/0x1b
[   28.937776]  [<c05a7504>] bus_add_driver+0x7e/0x1a5
[   28.943567]  [<c05a80cf>] driver_register+0x45/0x75
[   28.949358]  [<c053e4a5>] __pci_register_driver+0x56/0x84
[   28.955678]  [<c0819118>] rtl8139_init_module+0x14/0x1c
[   28.961832]  [<c0800521>] kernel_init+0x132/0x306
[   28.967451]  [<c0404fb3>] kernel_thread_helper+0x7/0x14
[   28.973588]  =======================
[   28.978151] initcall 0xc0819104: rtl8139_init_module+0x0/0x1c() returned 0.
[   28.986114] initcall 0xc0819104 ran for 161 msecs: rtl8139_init_module+0x0/0x1c()

http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.23-rc2-mm1/mm-dmesg
http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.23-rc2-mm1/mm-config

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
