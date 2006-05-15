From: "David Arnold" <david@mantara.com>
Subject: Re: skge driver oops
Date: Tue, 16 May 2006 07:55:37 +1000
Message-ID: <4176.1147730137@d.0x1.org>
References: <20060512085339.72faaa44@localhost.localdomain>
Reply-To: "David Arnold" <david@mantara.com>
Cc: "David Arnold" <david@mantara.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adl2.internode.on.net ([203.16.214.181]:28683 "EHLO
	smtp1.adl2.internode.on.net") by vger.kernel.org with ESMTP
	id S964825AbWEOVzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 17:55:48 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-reply-to: Your message of "Fri, 12 May 2006 08:53:39 MST."
             <20060512085339.72faaa44@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-->"Stephen" == Stephen Hemminger <shemminger@osdl.org> writes:

  >> i've been getting semi-regular lockups on my machine over 2.6.16
  >> series.  I recently attached a serial console in an attempt to
  >> capture an OOPS.

  Stephen> Could you retest with the v1.5 version that is 2.6.17-rc3?

using 2.6.17-rc4, i got

  BUG: unable to handle kernel NULL pointer dereference at virtual address 090
   printing eip:
  c11982de
  *pde = 0
  Oops: 0000 [#1]
  SMP
  Modules linked in: hci_usb i2c_amd756
  CPU: 0
  EIP: 0060:[<c11982de>] Not tainted VLI
  EFLAGS: 10283 (2.6.17rc4da #19)
  EIP is at skge_tx_complete+0x1e/0x50
  eax: 00000046 ebx: f772eb48 ecx: 00000000 edx: 00000000
  esi: f772eb3c edi: f7dd0700 ebp: c1500f54 esp: c1500f44
  ds: 007b es: 007b ss: 0068
  Process swapper (pid: 0, threadinfo=c1500000 task=c1443d00)
  Stack: <0>f755d200 f7dd0700 f772eb3c f772eb3c c1500fa4 c119cecd 00000000 00000296
         c1500f98 c1034bcc f7baa204 79e0b937 f7de0f20 f7dd0724 f76c2864 00000040
         00000000 f7dd0714 c1500000 c8560600 c14f7de0 f7dd04c0 f7dd0400 c1d6bb94
  Call Trace:
    <c1004165> show_stack_log_lvl+0xa5/0xf0
    <c10043cb> show_registers+0x1ab/0x240
    <c10046ae> die+0x12e/0x2d0
    <c1014e2a> do_page_fault+0x20a/0x6dc
    <c1003a4f> error_code+0x4f/0x54
    <c119cecd> skge_poll+0xcd/0x5e0
    <c12608fb> net_rx_action+0x8b/0x120
    <c1023154> __do_softirq+0x74/0xe0
    <c1005adc> do_softirq+0x5c/0x60
    ========================
    <c1022e29> irq_exit+0x39/0x50
    <c1005a5c> do_IRQ+0x4c/0x70
    <c100391a> common_interrupt+0x1a/0x20
    <c1001c34> cpu_idle+0x64/0x80
    <c10002d5> rest_init+0x35/0c40
    <c14c07ef> start_kernel+0x2ef/0x420
    <c1000210> 0xc1000210
  Code: 66 b8 e8 03 c3 90 8d b4 26 00 00 00 00 55 89 e5 57 89 c7 56 89 d6 53 83 ec 04 8b 58 14 39 d3 74 31 8b 4b 08 c7
  EIP: [<c11982de>] skge_tx_complete+0x1e/0x50 SS:ESP 0068:c1500f44
    <0>Kernel panic - not syncing: Fatal exception in interrupt





d
