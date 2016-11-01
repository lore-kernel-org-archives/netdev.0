From: Jakub Kicinski <kubakici@wp.pl>
Subject: new kmemleak reports (was: Re: [PATCH 0/5] genetlink improvements)
Date: Tue, 1 Nov 2016 17:28:40 +0000
Message-ID: <20161101172840.6d7d6278@jkicinski-Precision-T1700>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:16682 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751317AbcKAR2t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 13:28:49 -0400
In-Reply-To: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes!

Could these be related to your set?  Perhaps some annotation missing? :)

They are present on net-next but not on 4fe77d82ef80 ("skbedit: allow
the user to specify bitmask for mark").


unreferenced object 0xffff8807396a0348 (size 64):
  comm "swapper/0", pid 1, jiffies 4294898458 (age 781.352s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff888d0ecf>] genl_init+0x11/0x43
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff8807389cba28 (size 128):
  comm "swapper/0", pid 1, jiffies 4294898463 (age 781.332s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff888d9524>] netlbl_mgmt_genl_init+0x10/0x12
    [<ffffffff888d91e8>] netlbl_netlink_init+0x9/0x26
    [<ffffffff888d9254>] netlbl_init+0x4f/0x85
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff8807389c8f08 (size 128):
  comm "swapper/0", pid 1, jiffies 4294898463 (age 781.332s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff888d992f>] netlbl_cipsov4_genl_init+0x10/0x12
    [<ffffffff888d91f1>] netlbl_netlink_init+0x12/0x26
    [<ffffffff888d9254>] netlbl_init+0x4f/0x85
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88072dd23b08 (size 32):
  comm "swapper/0", pid 1, jiffies 4294898463 (age 781.348s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff888d9941>] netlbl_calipso_genl_init+0x10/0x12
    [<ffffffff888d91fa>] netlbl_netlink_init+0x1b/0x26
    [<ffffffff888d9254>] netlbl_init+0x4f/0x85
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff8807396a0828 (size 64):
  comm "swapper/0", pid 1, jiffies 4294898463 (age 781.348s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff888d9536>] netlbl_unlabel_genl_init+0x10/0x12
    [<ffffffff888d9203>] netlbl_netlink_init+0x24/0x26
    [<ffffffff888d9254>] netlbl_init+0x4f/0x85
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff880711df5ba8 (size 64):
  comm "swapper/0", pid 1, jiffies 4294898511 (age 781.160s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff88877dc4>] quota_init+0x10/0x24
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88072dc3e2e8 (size 16):
  comm "swapper/0", pid 1, jiffies 4294898513 (age 781.152s)
  hex dump (first 16 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff88898d4f>] acpi_event_init+0x4a/0x5e
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff880713975598 (size 16):
  comm "swapper/0", pid 1, jiffies 4294898569 (age 780.932s)
  hex dump (first 16 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff888bd402>] thermal_init+0x4f/0xdf
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff880715f52d08 (size 128):
  comm "swapper/0", pid 1, jiffies 4294898660 (age 780.584s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff888d1e5e>] tcp_metrics_init+0x31/0x48
    [<ffffffff888d1b89>] tcp_init+0x5af/0x5e1
    [<ffffffff888d2747>] inet_init+0x216/0x34b
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff8806fdc3eac8 (size 256):
  comm "swapper/0", pid 1, jiffies 4294900250 (age 774.292s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff888d0897>] devlink_module_init+0x10/0x12
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff8806fdff51e8 (size 64):
  comm "swapper/0", pid 1, jiffies 4294900263 (age 774.240s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
    [<ffffffff84771246>] __kmalloc+0x206/0x5a0
    [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
    [<ffffffff8885c8f7>] taskstats_init+0x11/0x37
    [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff85de7793>] kernel_init+0x13/0x140
    [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff


BTW this one is also relatively new (not present before 4.9-rc1 but
present on 4fe77d82ef80 already).  Not sure which commit could have
added that:

unreferenced object 0xffff8807383bfd48 (size 96):
  comm "swapper/0", pid 1, jiffies 4294894636 (age 278.320s)
  hex dump (first 32 bytes):
    a0 b4 b0 ba ff ff ff ff 00 00 00 00 01 00 00 00  ................
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffffb7de59e8>] kmemleak_alloc+0x28/0x50
    [<ffffffffb676e2f6>] __kmalloc+0x206/0x5a0
    [<ffffffffb69be2d3>] __register_sysctl_table+0xb3/0x1130
    [<ffffffffb69bf36b>] register_sysctl+0x1b/0x20
    [<ffffffffba840de1>] user_namespace_sysctl_init+0x17/0x4c
    [<ffffffffb60022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffffba7eb102>] kernel_init_freeable+0x597/0x636
    [<ffffffffb7de0433>] kernel_init+0x13/0x140
    [<ffffffffb7dfb36a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
