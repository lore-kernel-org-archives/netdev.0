From: Andrew Morton <akpm@linux-foundation.org>
Subject: powerpc allmodconfig
Date: Wed, 15 Oct 2008 21:33:37 -0700
Message-ID: <20081015213337.a99a9595.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org
To: Dan Williams <dan.j.williams@intel.com>, Takashi Iwai <tiwai@suse.de>,
	linux-ext4@vger.kernel.org, netdev@vger.kernel.org,
	linux-ide@vger.kernel.org,
	Bartlomiej Zolnierkiewicz <bzolni
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org



arch/powerpc/kernel/setup_64.c:447:5: warning: "kernstart_addr" is not defined
arch/powerpc/kernel/setup_64.c:447:5: warning: "kernstart_addr" is not defined


kernel/resource.c: In function '__reserve_region_with_split':
kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'resource_size_t'
kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 4 has type 'resource_size_t'
kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 6 has type 'resource_size_t'
kernel/resource.c:554: warning: format '%llx' expects type 'long long unsigned int', but argument 7 has type 'resource_size_t'


sound/soc/soc-dapm.c:1029: warning: 'snd_soc_dapm_connect_input' is deprecated (declared at sound/soc/soc-dapm.c:1026)
sound/soc/soc-dapm.c:1029: warning: 'snd_soc_dapm_connect_input' is deprecated (declared at sound/soc/soc-dapm.c:1026)
lib/debugobjects.c:58: warning: 'obj_states' defined but not used
net/dccp/options.c: In function 'dccp_parse_options':
net/dccp/options.c:67: warning: 'value' may be used uninitialized in this function


sound/soc/codecs/tlv320aic23.c: In function 'tlv320aic23_write':
sound/soc/codecs/tlv320aic23.c:104: warning: passing argument 2 of 'codec->hw_write' makes pointer from integer without a cast
sound/soc/codecs/tlv320aic23.c: In function 'tlv320aic23_set_dai_sysclk':
sound/soc/codecs/tlv320aic23.c:424: warning: unused variable 'codec'


drivers/dma/ioat_dca.c: In function 'dca_enabled_in_bios':
drivers/dma/ioat_dca.c:81: error: implicit declaration of function 'cpuid_eax'
drivers/dma/ioat_dca.c: In function 'system_has_dca_enabled':
drivers/dma/ioat_dca.c:91: error: implicit declaration of function 'boot_cpu_has'
drivers/dma/ioat_dca.c:91: error: 'X86_FEATURE_DCA' undeclared (first use in this function)
drivers/dma/ioat_dca.c:91: error: (Each undeclared identifier is reported only once
drivers/dma/ioat_dca.c:91: error: for each function it appears in.)
drivers/dma/ioat_dca.c: In function 'ioat_dca_get_tag':
drivers/dma/ioat_dca.c:190: error: implicit declaration of function 'cpu_physical_id'

fs/ext4/balloc.c: In function 'ext4_claim_free_blocks':
fs/ext4/balloc.c:607: warning: format '%lld' expects type 'long long int', but argument 2 has type 's64'
fs/ext4/inode.c: In function 'ext4_print_free_blocks':
fs/ext4/inode.c:1822: warning: format '%lld' expects type 'long long int', but argument 2 has type 's64'
fs/ext4/inode.c:1824: warning: format '%lld' expects type 'long long int', but argument 2 has type 's64'

net/sched/sch_generic.c: In function 'dev_watchdog':
net/sched/sch_generic.c:224: warning: unused variable 'drivername'


net/mac80211/rc80211_minstrel_debugfs.c: In function 'minstrel_stats_open':
net/mac80211/rc80211_minstrel_debugfs.c:98: warning: format '%8llu' expects type 'long long unsigned int', but argument 11 has type 'u64'
net/mac80211/rc80211_minstrel_debugfs.c:98: warning: format '%8llu' expects type 'long long unsigned int', but argument 12 has type 'u64'
net/mac80211/rc80211_minstrel_debugfs.c:98: warning: format '%8llu' expects type 'long long unsigned int', but argument 11 has type 'u64'
net/mac80211/rc80211_minstrel_debugfs.c:98: warning: format '%8llu' expects type 'long long unsigned int', but argument 12 has type 'u64'
net/mac80211/rc80211_minstrel_debugfs.c: At top level:
net/mac80211/rc80211_minstrel_debugfs.c:145: warning: initialization from incompatible pointer type

drivers/ide/pci/scc_pata.c: In function 'init_hwif_scc':
drivers/ide/pci/scc_pata.c:846: warning: unused variable 'ports'
drivers/ide/pci/hpt366.c: In function 'init_hwif_hpt366':
drivers/ide/pci/hpt366.c:1292: warning: unused variable 'dev'

include/linux/ucb1400.h:139: warning: 'ucb1400_adc_read' defined but not used

drivers/mtd/devices/docprobe.c:80:2: warning: #warning Unknown architecture for DiskOnChip. No default probe locations defined

fs/ocfs2/xattr.c: In function 'ocfs2_xattr_index_block_find':
fs/ocfs2/xattr.c:2400: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:2400: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:2400: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_iterate_xattr_buckets':
fs/ocfs2/xattr.c:2424: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:2424: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:2424: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:2443: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:2443: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:2443: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_xattr_create_index_block':
fs/ocfs2/xattr.c:2779: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:2779: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:2779: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_defrag_xattr_bucket':
fs/ocfs2/xattr.c:2942: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:2942: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:2942: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_mv_xattr_bucket_cross_cluster':
fs/ocfs2/xattr.c:3060: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3060: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3060: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3060: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3060: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3060: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_half_xattr_bucket':
fs/ocfs2/xattr.c:3189: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3189: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3189: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3189: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3189: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3189: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_cp_xattr_bucket':
fs/ocfs2/xattr.c:3360: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3360: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3360: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3360: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3360: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3360: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_cp_xattr_cluster':
fs/ocfs2/xattr.c:3431: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3431: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3431: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3431: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3431: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3431: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_adjust_xattr_cross_cluster':
fs/ocfs2/xattr.c:3561: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3561: warning: format '%llu' expects type 'long long unsigned int', but argument 8 has type 'u64'
fs/ocfs2/xattr.c:3561: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3561: warning: format '%llu' expects type 'long long unsigned int', but argument 8 has type 'u64'
fs/ocfs2/xattr.c:3561: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3561: warning: format '%llu' expects type 'long long unsigned int', but argument 8 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_add_new_xattr_cluster':
fs/ocfs2/xattr.c:3629: warning: format '%llu' expects type 'long long unsigned int', but argument 8 has type 'u64'
fs/ocfs2/xattr.c:3629: warning: format '%llu' expects type 'long long unsigned int', but argument 8 has type 'u64'
fs/ocfs2/xattr.c:3629: warning: format '%llu' expects type 'long long unsigned int', but argument 8 has type 'u64'
fs/ocfs2/xattr.c:3718: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3718: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c:3718: warning: format '%llu' expects type 'long long unsigned int', but argument 7 has type 'u64'
fs/ocfs2/xattr.c: In function 'ocfs2_extend_xattr_bucket':
fs/ocfs2/xattr.c:3763: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3763: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'
fs/ocfs2/xattr.c:3763: warning: format '%llu' expects type 'long long unsigned int', but argument 6 has type 'u64'

sound/pci/hda/patch_sigmatel.c: In function 'stac92xx_parse_auto_config':
sound/pci/hda/patch_sigmatel.c:2819: warning: 'nid' may be used uninitialized in this function

drivers/rtc/rtc-ds1286.c: In function 'ds1286_rtc_read':
drivers/rtc/rtc-ds1286.c:33: error: implicit declaration of function '__raw_readl'
drivers/rtc/rtc-ds1286.c: In function 'ds1286_rtc_write':
drivers/rtc/rtc-ds1286.c:38: error: implicit declaration of function '__raw_writel'
drivers/rtc/rtc-ds1286.c: In function 'ds1286_probe':
drivers/rtc/rtc-ds1286.c:345: error: implicit declaration of function 'ioremap'
drivers/rtc/rtc-ds1286.c:345: warning: assignment makes pointer from integer without a cast
drivers/rtc/rtc-ds1286.c:365: error: implicit declaration of function 'iounmap'
make[2]: [drivers/rtc/rtc-ds1286.o] Error 1 (ignored)



drivers/serial/serial_txx9.c: In function 'serial_txx9_probe':
drivers/serial/serial_txx9.c:1041: warning: format '%x' expects type 'unsigned int', but argument 5 has type 'long unsigned int'



drivers/rtc/rtc-m48t35.c: In function 'm48t35_read_time':
drivers/rtc/rtc-m48t35.c:59: error: implicit declaration of function 'readb'
drivers/rtc/rtc-m48t35.c:60: error: implicit declaration of function 'writeb'
drivers/rtc/rtc-m48t35.c: In function 'm48t35_probe':
drivers/rtc/rtc-m48t35.c:168: error: implicit declaration of function 'ioremap'
drivers/rtc/rtc-m48t35.c:168: warning: assignment makes pointer from integer without a cast
drivers/rtc/rtc-m48t35.c:188: error: implicit declaration of function 'iounmap'



drivers/net/ibm_newemac/mal.c: In function 'mal_txeob':
drivers/net/ibm_newemac/mal.c:284: error: implicit declaration of function 'mtdcri'
drivers/net/ibm_newemac/mal.c:284: error: 'SDR0' undeclared (first use in this function)
drivers/net/ibm_newemac/mal.c:284: error: (Each undeclared identifier is reported only once
drivers/net/ibm_newemac/mal.c:284: error: for each function it appears in.)
drivers/net/ibm_newemac/mal.c:285: error: implicit declaration of function 'mfdcri'
drivers/net/ibm_newemac/mal.c: In function 'mal_rxeob':
drivers/net/ibm_newemac/mal.c:302: error: 'SDR0' undeclared (first use in this function)



drivers/media/dvb/frontends/cx24116.c: In function 'cx24116_load_firmware':
drivers/media/dvb/frontends/cx24116.c:573: warning: passing argument 3 of 'cx24116_writeregN' discards qualifiers from pointer target type



drivers/video/aty/aty128fb.c: In function 'aty128_decode_var':
drivers/video/aty/aty128fb.c:1520: warning: 'pll.post_divider' may be used uninitialized in this function



drivers/net/wireless/libertas_tf/if_usb.c: In function '__if_usb_submit_rx_urb':
drivers/net/wireless/libertas_tf/if_usb.c:334: warning: cast to pointer from integer of different size


drivers/media/dvb/frontends/z0194a.h:85: warning: 'sharp_z0194a_config' defined but not used
drivers/media/video/gspca/ov519.c: In function 'mode_init_ov_sensor_regs':
drivers/media/video/gspca/ov519.c:1670: warning: comparison is always true due to limited range of data type



Documentation/video4linux/v4lgrab.c: In function 'main':
Documentation/video4linux/v4lgrab.c:184: warning: 'src_depth' is used uninitialized in this function
Documentation/video4linux/v4lgrab.c:99: warning: 'b' may be used uninitialized in this function
Documentation/video4linux/v4lgrab.c:99: warning: 'g' may be used uninitialized in this function
Documentation/video4linux/v4lgrab.c:99: warning: 'r' may be used uninitialized in this function
Documentation/accounting/getdelays.c: In function 'main':
Documentation/accounting/getdelays.c:249: warning: 'cmd_type' may be used uninitialized in this function
Documentation/connector/cn_test.c:45: warning: 'cn_test_want_notify' defined but not used
