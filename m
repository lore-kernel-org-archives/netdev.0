From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Subject: [ANNOUNCE] backports-3.14-1 released
Date: Thu, 17 Apr 2014 19:06:02 -0700
Message-ID: <1397786762-17656-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Linux backports [0] backports-v3.14-1 is out [1]. Thanks for Hauke
for taking the torch while I was in limbo. The release obviously
has all the things that upstream has so there's no point in mentioning
any of that, but new drivers are igb, added by Stefan. This release
also has a new backports-update-manager under devel/ which will do
what you expect -- download any new kernels / keep trees in sycn and
remove any stale once we stop supporting them. One of the biggest changes
here is also the more extensive use of Coccinelle SmPL grammar [2] to
help further with automatic backports. I've written a piece of great
lengh to get people excited about the potential here. Hopefully, more
than anything, you'll just see by example how we do things better with
SmPL.

[0] https://backports.wiki.kernel.org/
[1] http://www.kernel.org/pub/linux/kernel/projects/backports/stable/v3.14/backports-3.14-1.tar.xz
[2] http://coccinelle.lip6.fr/
[3] http://www.do-not-panic.com/2014/04/automatic-linux-kernel-backporting-with-coccinelle.html

Eliad Peller (1):
      backports: ifdef some pci functions

Emmanuel Grumbach (2):
      backports: add support for prandom_bytes
      backports: fix iwlwifi threaded IRQ patches

Hauke Mehrtens (98):
      backports: remove mdio driver code
      backports: remove eeprom_93cx6.h header
      backports: remove acpi_video_register_with_quirks()
      backports: remove atomic_inc_not_zero_hint()
      backports: remove irq_set_affinity_hint()
      backports: remove efi
      backports: remove ethtool_rxfh_indir_default()
      backports: remove fb_enable_skip_vt_switch()
      backports: remove vlan_hw_offload_capable()
      backports: remove hex_byte_pack()
      backports: remove kref_get_unless_zero()
      backports: remove usb_unlink_anchored_urbs()
      backports: remove backport/backport-include/linux/vgaarb.h
      backports: remove own version of include/linux/wireless.h
      backports: remove own version of include/linux/unaligned/*.h
      backports: check for define in module_driver and not kernel version
      backports: add backport_ prefix in front of BQL functions
      backports: remove duplicate allyesconfig from help
      backports: add backport_ in front of sign_extend32()
      backports: refresh patches on next-20131129
      backports: remove DMI_EXACT_MATCH
      backports: add missing include for linux/of.h
      backports: add LINUX_BACKPORT infront of functions
      backports: remove unused workqueue backports
      backports: so not add netdev_features_t on RHEL 6.5
      backports: add missing LINUX_BACKPORT() on various places
      backports: fix skb_add_rx_fragi() for SLES 11 SP3
      backports: do not call dev_hw_addr_random()
      backports: add devm_kmalloc()
      backports: add netdev_notify_peers()
      backports: add ARPHRD_6LOWPAN
      backports: add include/trace/events/v4l2.h file
      backports: fix number of arguments of phy_connect()
      backports: make b44 depend on kernel > 2.6.28
      backports: remove usage of members of struct property for kernel < 2.6.39
      backports: add include/net/af_ieee802154.h file
      backports: remove usage of addr_assign_type in 6lowpan.c
      backports: remove CRC8 backport
      backports: add printk_ratelimited()
      backports: build some regulator drivers only with recent kernels
      backports: copy include/uapi/linux/vsp1.h
      backports: fix i2c_add_mux_adapter() parameters
      backports: update kernel versions
      backports: refresh on next-20131224
      backports: add prefix infront of led_blink_set()
      backports: add missing include
      gentree: create *.tar.gz instead of *.tar.bz for kernel.org
      backports: add ether_addr_equal_64bits()
      backports: add ether_addr_equal_unaligned()
      backports: do not build ACT8865 with kernel < 3.12
      backports: add missing header file
      backports: refresh on next-20140106
      backports: adapt to changes in netdev select_queue call
      backports: add USB_DEVICE_INTERFACE_CLASS
      backports: do not activate BCMA_HOST_SOC on kernel < 3.7
      backports: add sdio device id list
      backports: add ATTRIBUTE_GROUPS unconditionally
      backports: add linux/irqdomain.h
      backports: fix header of phy_mii_ioctl()
      backports: backport get_stats in alx driver
      backports: add IS_BUILTIN()
      backports: add prefix infront of ether_addr_equal_{unaligned, 64bits}()
      backports: fix led_trigger warning with old kernel versions
      backports: fix unused mwifiex_sdio_resume() warning
      backports: fix unused var ret warning
      backports: fix unused atl1e_rx_mode() warning
      backports: fix unused hidp_get_raw_report() warning
      backports: refresh on next-20140117
      backports: add DECLARE_SOCKADDR
      backports: add __sockaddr_check_size()
      backports: always access net/ieee802154/ with make
      backports: refresh on next-20140124
      backports: fix uninstall filename
      backports: refresh on next-20140131
      backports: add led_trigger_blink{_oneshot}()
      backports: remove bluetooth HIDP transport-driver functions
      backports: add compat_put_timespec()
      backports: update sch_fq_codel_core.c
      backports: update test kernel versions
      backports: refresh patches on next-20140207
      backports: REGULATOR_S5M8767 depends on kernel 3.15
      backports: add ipv6_addr_hash()
      backports: add ETH_P_TEB and ETH_P_8021AD
      backports: copy cordic from kernel
      backports: copy sch_codel.c from kernel
      backports: copy sch_fq_codel.c from kernel
      backports: fix indenting
      backports: add atomic64_set()
      backports: add VHCI_MINOR
      backports: add snd_card_new()
      backports: add pci_enable_msi_range()
      backports: add pci_enable_msix_range()
      backports: add devm_kstrdup()
      backports: add of_property_count_u32_elems()
      backports: add of_property_read_u32_index()
      backports: add NLA_S{9,16,32,64}
      backports: remove usage of net_device member qdisc_tx_busylock
      backports: refresh patches on next-20140221

Ido Yariv (1):
      backports: backport ACPI_HANDLE(dev)

Johannes Berg (9):
      ckmake: sort kernel releases properly
      backports: backport hex2bin()
      gentree: combine spatches (unless using --gitdebug)
      backports: backport multicast list handling in iwlwifi mvm
      backports: backport power efficient workqueues
      backports: make BACKPORT_BUILD_LEDS depend on LEDS_CLASS=n
      backports: conditionally access net/ieee802154/ with make
      backports: fix compilation with CONFIG_OF
      backports: add crypto/ccm backport

Luis R. Rodriguez (25):
      backports: backport ktime_to_ms()
      backports: backport getrawmonotonic() with do_posix_clock_monotonic_gettime()
      backports: refresh patches for next-20131206
      backports: add Python based backports-update-manager
      backports: convert the 62-usb_driver_lpm patch series to SmPL
      backports: convert 11-dev-pm-ops patch series to SmPL
      backports: refresh patches for next-20131206 a second time
      backports: backport MPLS support
      backports: make WL1251_SPI depend on >= 3.5
      backports: bump kernel reqs for WL1251_SDIO and WLCORE_SDIO
      backports: bump drivers dependency that require I2C bus classes
      backports: define ETH_P_80221
      backports: backport definition of struct frag_queue
      backports: backport skb_unclone()
      backports: backport frag helper functions for mem limit tracking
      backports: backport inet_frag_maybe_warn_overflow()
      backports: add threaded Coccinelle spatch support
      backports: use --ignore-removal for git add
      backports: add git diff support to lib/bpgit.py
      backports: add support for testing only a single Coccinelle SmPL patch
      backports: add Coccinelle SmPL profiling support to gentree.py
      Revert "backports: backport MPLS support"
      backports: remove bluetooth HIDP backport
      backports: bump bluetooth backport to require >= 2.6.39
      backports: refresh patches for v3.14

Stefan Assmann (12):
      backports: igb fixes for linux-3.13
      backports: igb fixes for linux-3.12
      backports: igb fixes for linux-3.9
      backports: igb fixes for linux-3.8
      backports: igb fixes for linux-3.7
      backports: igb fixes for linux-3.6
      backports: igb fixes for linux-3.5
      backports: igb fixes for linux-3.4
      backports: igb fixes for linux-3.3
      backports: igb fixes for linux-3.2
      backports: igb fixes for linux-3.1
      backports: enable igb and add defconfig


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/NeoTech
