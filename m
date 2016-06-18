From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCHv2 2/2] mt7601u: use linux/bitfield.h
Date: Sun, 19 Jun 2016 06:08:17 +0800
Message-ID: <201606190608.Z8IkMv3G%fengguang.wu@intel.com>
References: <1465904660-22242-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	hannes@stressinduktion.org, nbd@nbd.name,
	linux-kernel@vger.kernel.org, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465904660-22242-3-git-send-email-jakub.kicinski@netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test ERROR on wireless-drivers-next/master]
[also build test ERROR on v4.7-rc3 next-20160617]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Jakub-Kicinski/register-field-manipulation-macros/20160614-195149
base:   https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git master
config: x86_64-randconfig-s4-06190511 (attached as .config)
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All error/warnings (new ones prefixed by >>):

   In file included from include/asm-generic/bug.h:4:0,
                    from arch/x86/include/asm/bug.h:35,
                    from include/linux/bug.h:4,
                    from include/linux/bitfield.h:19,
                    from drivers/net/wireless/mediatek/mt7601u/mt7601u.h:18,
                    from drivers/net/wireless/mediatek/mt7601u/init.c:16:
   In function 'mt7601u_init_usb_dma',
       inlined from 'mt7601u_init_hardware' at drivers/net/wireless/mediatek/mt7601u/init.c:359:2:
>> include/linux/compiler.h:510:38: error: call to '__compiletime_assert_111' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(0x80) ? ~(((((~0UL) << (0)) & (~0UL >> (64 - 1 - (7))))) >> _bf_shf((((~0UL) << (0)) & (~0UL >> (64 - 1 - (7)))))) & (0x80) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:493:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/init.c:111:8: note: in expansion of macro 'MT76_SET'
     val = MT76_SET(MT_USB_DMA_CFG_RX_BULK_AGG_TOUT, MT_USB_AGGR_TIMEOUT) |
           ^~~~~~~~
   include/linux/compiler.h:510:38: error: call to '__compiletime_assert_112' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(28) ? ~(((((~0UL) << (8)) & (~0UL >> (64 - 1 - (15))))) >> _bf_shf((((~0UL) << (8)) & (~0UL >> (64 - 1 - (15)))))) & (28) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:493:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
   drivers/net/wireless/mediatek/mt7601u/init.c:112:8: note: in expansion of macro 'MT76_SET'
           MT76_SET(MT_USB_DMA_CFG_RX_BULK_AGG_LMT, MT_USB_AGGR_SIZE_LIMIT) |
           ^~~~~~~~
   drivers/net/wireless/mediatek/mt7601u/init.c: In function 'mt7601u_init_hardware':
   include/linux/compiler.h:510:38: error: call to '__compiletime_assert_399' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(0x3f) ? ~(((((~0UL) << (0)) & (~0UL >> (64 - 1 - (5))))) >> _bf_shf((((~0UL) << (0)) & (~0UL >> (64 - 1 - (5)))))) & (0x3f) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:493:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
   drivers/net/wireless/mediatek/mt7601u/init.c:399:36: note: in expansion of macro 'MT76_SET'
     mt7601u_wr(dev, MT_TXOP_CTRL_CFG, MT76_SET(MT_TXOP_TRUN_EN, 0x3f) |
                                       ^~~~~~~~
   include/linux/compiler.h:510:38: error: call to '__compiletime_assert_400' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(0x58) ? ~(((((~0UL) << (8)) & (~0UL >> (64 - 1 - (15))))) >> _bf_shf((((~0UL) << (8)) & (~0UL >> (64 - 1 - (15)))))) & (0x58) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:493:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
   drivers/net/wireless/mediatek/mt7601u/init.c:400:8: note: in expansion of macro 'MT76_SET'
           MT76_SET(MT_TXOP_EXT_CCA_DLY, 0x58));
           ^~~~~~~~
--
   In file included from include/linux/byteorder/little_endian.h:4:0,
                    from arch/x86/include/uapi/asm/byteorder.h:4,
                    from include/asm-generic/bitops/le.h:5,
                    from arch/x86/include/asm/bitops.h:504,
                    from include/linux/bitops.h:36,
                    from include/linux/kernel.h:10,
                    from drivers/net/wireless/mediatek/mt7601u/mcu.c:16:
   drivers/net/wireless/mediatek/mt7601u/mcu.c: In function '__mt7601u_dma_fw':
>> include/linux/compiler.h:510:38: error: call to '__compiletime_assert_294' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(len) ? ~(((((~0UL) << (0)) & (~0UL >> (64 - 1 - (15))))) >> _bf_shf((((~0UL) << (0)) & (~0UL >> (64 - 1 - (15)))))) & (len) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/uapi/linux/byteorder/little_endian.h:32:51: note: in definition of macro '__cpu_to_le32'
    #define __cpu_to_le32(x) ((__force __le32)(__u32)(x))
                                                      ^
>> include/linux/compiler.h:498:2: note: in expansion of macro '__compiletime_assert'
     __compiletime_assert(condition, msg, prefix, suffix)
     ^~~~~~~~~~~~~~~~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mcu.c:294:20: note: in expansion of macro 'MT76_SET'
     reg = cpu_to_le32(MT76_SET(MT_TXD_INFO_TYPE, DMA_PACKET) |
                       ^~~~~~~~
>> include/linux/compiler.h:510:38: error: call to '__compiletime_assert_294' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(len) ? ~(((((~0UL) << (0)) & (~0UL >> (64 - 1 - (15))))) >> _bf_shf((((~0UL) << (0)) & (~0UL >> (64 - 1 - (15)))))) & (len) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/uapi/linux/byteorder/little_endian.h:32:51: note: in definition of macro '__cpu_to_le32'
    #define __cpu_to_le32(x) ((__force __le32)(__u32)(x))
                                                      ^
>> include/linux/compiler.h:498:2: note: in expansion of macro '__compiletime_assert'
     __compiletime_assert(condition, msg, prefix, suffix)
     ^~~~~~~~~~~~~~~~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
   drivers/net/wireless/mediatek/mt7601u/mcu.c:295:6: note: in expansion of macro 'MT76_SET'
         MT76_SET(MT_TXD_INFO_D_PORT, CPU_TX_PORT) |
         ^~~~~~~~
>> include/linux/compiler.h:510:38: error: call to '__compiletime_assert_294' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(len) ? ~(((((~0UL) << (0)) & (~0UL >> (64 - 1 - (15))))) >> _bf_shf((((~0UL) << (0)) & (~0UL >> (64 - 1 - (15)))))) & (len) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/uapi/linux/byteorder/little_endian.h:32:51: note: in definition of macro '__cpu_to_le32'
    #define __cpu_to_le32(x) ((__force __le32)(__u32)(x))
                                                      ^
>> include/linux/compiler.h:498:2: note: in expansion of macro '__compiletime_assert'
     __compiletime_assert(condition, msg, prefix, suffix)
     ^~~~~~~~~~~~~~~~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
   drivers/net/wireless/mediatek/mt7601u/mcu.c:296:6: note: in expansion of macro 'MT76_SET'
         MT76_SET(MT_TXD_INFO_LEN, len));
         ^~~~~~~~
   In file included from arch/x86/include/asm/bug.h:35:0,
                    from include/linux/bug.h:4,
                    from include/linux/mmdebug.h:4,
                    from include/linux/gfp.h:4,
                    from include/linux/firmware.h:6,
                    from drivers/net/wireless/mediatek/mt7601u/mcu.c:17:
   In function 'mt7601u_dma_skb_wrap_cmd',
       inlined from 'mt7601u_mcu_msg_send' at drivers/net/wireless/mediatek/mt7601u/mcu.c:135:2:
>> include/linux/compiler.h:510:38: error: call to '__compiletime_assert_47' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(cmd) ? ~(((((~0UL) << (20)) & (~0UL >> (64 - 1 - (26))))) >> _bf_shf((((~0UL) << (20)) & (~0UL >> (64 - 1 - (26)))))) & (cmd) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/asm-generic/bug.h:92:25: note: in definition of macro 'WARN_ON'
     int __ret_warn_on = !!(condition);    \
                            ^~~~~~~~~
>> include/linux/compiler.h:498:2: note: in expansion of macro '__compiletime_assert'
     __compiletime_assert(condition, msg, prefix, suffix)
     ^~~~~~~~~~~~~~~~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
--
   In file included from include/asm-generic/bug.h:4:0,
                    from arch/x86/include/asm/bug.h:35,
                    from include/linux/bug.h:4,
                    from include/linux/bitfield.h:19,
                    from drivers/net/wireless/mediatek/mt7601u/mt7601u.h:18,
                    from drivers/net/wireless/mediatek/mt7601u/dma.c:14:
   In function 'mt7601u_rx_process_seg',
       inlined from 'mt7601u_rx_process_entry' at drivers/net/wireless/mediatek/mt7601u/dma.c:151:3,
       inlined from 'mt7601u_rx_tasklet' at drivers/net/wireless/mediatek/mt7601u/dma.c:219:3:
   include/linux/compiler.h:510:38: error: call to '__compiletime_assert_106' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(0) ? ~(((((~0UL) << (30)) & (~0UL >> (64 - 1 - (31))))) >> _bf_shf((((~0UL) << (30)) & (~0UL >> (64 - 1 - (31)))))) & (0) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:170:42: note: in definition of macro 'unlikely'
    # define unlikely(x) __builtin_expect(!!(x), 0)
                                             ^
>> include/linux/compiler.h:498:2: note: in expansion of macro '__compiletime_assert'
     __compiletime_assert(condition, msg, prefix, suffix)
     ^~~~~~~~~~~~~~~~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
   include/linux/bitfield.h:42:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, 0);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:286:18: note: in expansion of macro 'FIELD_GET'
    #define MT76_GET FIELD_GET
                     ^~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/dma.c:106:15: note: in expansion of macro 'MT76_GET'
     if (unlikely(MT76_GET(MT_RXD_INFO_TYPE, fce_info)))
                  ^~~~~~~~
   In file included from include/asm-generic/bug.h:4:0,
                    from arch/x86/include/asm/bug.h:35,
                    from include/linux/bug.h:4,
                    from include/linux/bitfield.h:19,
                    from drivers/net/wireless/mediatek/mt7601u/mt7601u.h:18,
                    from drivers/net/wireless/mediatek/mt7601u/dma.c:14:
   In function 'mt7601u_dma_skb_wrap_pkt',
       inlined from 'mt7601u_dma_enqueue_tx' at drivers/net/wireless/mediatek/mt7601u/dma.c:350:6:
>> include/linux/compiler.h:510:38: error: call to '__compiletime_assert_91' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(qsel) ? ~(((((~0UL) << (25)) & (~0UL >> (64 - 1 - (26))))) >> _bf_shf((((~0UL) << (25)) & (~0UL >> (64 - 1 - (26)))))) & (qsel) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:493:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
   drivers/net/wireless/mediatek/mt7601u/dma.h:91:11: note: in expansion of macro 'MT76_SET'
     flags |= MT76_SET(MT_TXD_PKT_INFO_QSEL, qsel);
              ^~~~~~~~
   In function 'mt7601u_dma_skb_wrap.constprop',
       inlined from 'mt7601u_dma_skb_wrap_pkt' at drivers/net/wireless/mediatek/mt7601u/dma.h:92:9,
       inlined from 'mt7601u_dma_enqueue_tx' at drivers/net/wireless/mediatek/mt7601u/dma.c:350:6:
>> include/linux/compiler.h:510:38: error: call to '__compiletime_assert_80' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(((((skb->len)-1) | ((__typeof__(skb->len))((4)-1)))+1)) ? ~(((((~0UL) << (0)) & (~0UL >> (64 - 1 - (15))))) >> _bf_shf((((~0UL) << (0)) & (~0UL >> (64 - 1 - (15)))))) & (((((skb->len)-1) | ((__typeof__(skb->len))((4)-1)))+1)) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:493:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/dma.h:80:3: note: in expansion of macro 'MT76_SET'
      MT76_SET(MT_TXD_INFO_LEN, round_up(skb->len, 4)) |
      ^~~~~~~~
>> include/linux/compiler.h:510:38: error: call to '__compiletime_assert_81' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(d_port) ? ~(((((~0UL) << (27)) & (~0UL >> (64 - 1 - (29))))) >> _bf_shf((((~0UL) << (27)) & (~0UL >> (64 - 1 - (29)))))) & (d_port) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:493:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
>> drivers/net/wireless/mediatek/mt7601u/mt7601u.h:285:18: note: in expansion of macro 'FIELD_PUT'
    #define MT76_SET FIELD_PUT
                     ^~~~~~~~~
   drivers/net/wireless/mediatek/mt7601u/dma.h:81:3: note: in expansion of macro 'MT76_SET'
      MT76_SET(MT_TXD_INFO_D_PORT, d_port) |
      ^~~~~~~~
>> include/linux/compiler.h:510:38: error: call to '__compiletime_assert_82' declared with attribute error: BUILD_BUG_ON failed: __builtin_constant_p(type) ? ~(((((~0UL) << (30)) & (~0UL >> (64 - 1 - (31))))) >> _bf_shf((((~0UL) << (30)) & (~0UL >> (64 - 1 - (31)))))) & (type) : 0
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:493:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \
       ^~~~~~
   include/linux/compiler.h:510:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
     ^~~~~~~~~~~~~~~~~~~
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                        ^~~~~~~~~~~~~~~~~~
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
     ^~~~~~~~~~~~~~~~
>> include/linux/bitfield.h:28:3: note: in expansion of macro 'BUILD_BUG_ON'
      BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
      ^~~~~~~~~~~~
>> include/linux/bitfield.h:36:3: note: in expansion of macro '_BF_FIELD_CHECK'
      _BF_FIELD_CHECK(_mask, _val);   \
      ^~~~~~~~~~~~~~~
..

vim +/__compiletime_assert_111 +510 include/linux/compiler.h

9a8ab1c3 Daniel Santos  2013-02-21  492  		if (__cond)						\
9a8ab1c3 Daniel Santos  2013-02-21  493  			prefix ## suffix();				\
9a8ab1c3 Daniel Santos  2013-02-21  494  		__compiletime_error_fallback(__cond);			\
9a8ab1c3 Daniel Santos  2013-02-21  495  	} while (0)
9a8ab1c3 Daniel Santos  2013-02-21  496  
9a8ab1c3 Daniel Santos  2013-02-21  497  #define _compiletime_assert(condition, msg, prefix, suffix) \
9a8ab1c3 Daniel Santos  2013-02-21 @498  	__compiletime_assert(condition, msg, prefix, suffix)
9a8ab1c3 Daniel Santos  2013-02-21  499  
9a8ab1c3 Daniel Santos  2013-02-21  500  /**
9a8ab1c3 Daniel Santos  2013-02-21  501   * compiletime_assert - break build and emit msg if condition is false
9a8ab1c3 Daniel Santos  2013-02-21  502   * @condition: a compile-time constant condition to check
9a8ab1c3 Daniel Santos  2013-02-21  503   * @msg:       a message to emit if condition is false
9a8ab1c3 Daniel Santos  2013-02-21  504   *
9a8ab1c3 Daniel Santos  2013-02-21  505   * In tradition of POSIX assert, this macro will break the build if the
9a8ab1c3 Daniel Santos  2013-02-21  506   * supplied condition is *false*, emitting the supplied error message if the
9a8ab1c3 Daniel Santos  2013-02-21  507   * compiler has support to do so.
9a8ab1c3 Daniel Santos  2013-02-21  508   */
9a8ab1c3 Daniel Santos  2013-02-21  509  #define compiletime_assert(condition, msg) \
9a8ab1c3 Daniel Santos  2013-02-21 @510  	_compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
9a8ab1c3 Daniel Santos  2013-02-21  511  
47933ad4 Peter Zijlstra 2013-11-06  512  #define compiletime_assert_atomic_type(t)				\
47933ad4 Peter Zijlstra 2013-11-06  513  	compiletime_assert(__native_word(t),				\

:::::: The code at line 510 was first introduced by commit
:::::: 9a8ab1c39970a4938a72d94e6fd13be88a797590 bug.h, compiler.h: introduce compiletime_assert & BUILD_BUG_ON_MSG

:::::: TO: Daniel Santos <daniel.santos@pobox.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--2oS5YaxWCcQjTEyO
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
p9Lc7f0PDBk5InsUAgA=

--2oS5YaxWCcQjTEyO--
