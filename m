From: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2010-05-28
Date: Sat, 29 May 2010 15:34:31 +0200
Message-ID: <AANLkTil8SLseSeq1M_Xg7P4AqMy3V_0jxc7by2Xuaqnb@mail.gmail.com>
References: <20100528180952.GC2405@tuxdriver.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jiajia.zheng-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Abhijeet Kolekar <abhijeet.kolekar-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100528180952.GC2405-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I have pulled wireless-2.6 GIT (master-2010-05-28) into Linus-tree
(2.6.34-git15) [0] and Intel Linux-Wireless Bug #2208 is present.

Two people confirmed the patch in [2] fixes:
1. iwlwifi-2.6 GIT master (commit f10a237c95abd6d64a3a24553bd1d3bcddd91=
08b)
2. compat-wireless (2010-05-21)

And it fixes also the above mentionned combination.

As a suggestion:
What about "copying" bug-reports (incl. its history) from IWL-BTS into
linux-wireless ML?
=46or example (dri-devel related) bug-reports from
bugzilla.freedesktop.org are "copied" into dri-devel ML.

Hope [2] gets quickly into wireless-2.6 GIT.

Kind Regards,
- Sedat -

References:
------------------
[0] commit 24010e460454ec0d2f4f0213b667b4349cbdb8e1:
Merge branch 'drm-linus' of git://git./linux/kernel/git/airlied/drm-2.6
[1] http://bugzilla.intellinuxwireless.org/show_bug.cgi?id=3D2208
[2] http://bugzilla.intellinuxwireless.org/attachment.cgi?id=3D2447
[3] http://bugzilla.intellinuxwireless.org/show_bug.cgi?id=3D2208#c8
[4] http://bugzilla.intellinuxwireless.org/show_bug.cgi?id=3D2208#c9

[  446.893181] BUG: unable to handle kernel NULL pointer dereference at=
 (null)
[  446.893192] IP: [<f8e9eb54>]
iwl3945_get_channels_for_scan+0xb4/0x315 [iwl3945]
[  446.893214] *pde =3D 00000000
[  446.893220] Oops: 0000 [#1] PREEMPT SMP
[  446.893228] last sysfs file:
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
[  446.893233] Modules linked in: btrfs zlib_deflate crc32c libcrc32c
ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs xfs exportfs
reiserfs ext2 radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core
acpi_cpufreq mperf cpufreq_ondemand cpufreq_stats freq_table
cpufreq_performance cpufreq_conservative cpufreq_powersave sco bridge
stp bnep rfcomm l2cap bluetooth aes_i586 aes_generic ppdev lp
kvm_intel kvm binfmt_misc ipv6 af_packet fuse ext4 jbd2 crc16
snd_hda_codec_si3054 snd_hda_codec_analog snd_hda_intel snd_hda_codec
snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss
snd_seq_midi arc4 snd_rawmidi ecb snd_seq_midi_event iwl3945 iwlcore
snd_seq snd_timer snd_seq_device sierra usbserial snd parport_pc
mac80211 hp_wmi parport soundcore snd_page_alloc cfg80211 rfkill
joydev pcmcia irda pcspkr intel_agp tifm_7xx1 tifm_core rng_core
iTCO_wdt iTCO_vendor_support hp_accel yenta_socket pcmcia_rsrc
pcmcia_core psmouse evdev tpm_infineon crc_ccitt wmi video output
serio_raw lis3lv02d container battery rtc_cmos tpm_tis tpm rtc_core
tpm_bios rtc_lib input_polldev ac processor button ext3 jbd mbcache
dm_mod usbhid hid sg sr_mod cdrom sd_mod fan pata_acpi ata_generic
sdhci_pci sdhci ata_piix uhci_hcd ahci libahci mmc_core led_class
ehci_hcd tg3 libata thermal scsi_mod usbcore nls_base [last unloaded:
i2c_core]
[  446.893460]
[  446.893466] Pid: 1312, comm: iwl3945 Not tainted
2.6.34-git15.sd.1-iniza-686-kms #1 30AC/HP Compaq nc6400 (RH572EA#ABD)
[  446.893473] EIP: 0060:[<f8e9eb54>] EFLAGS: 00010283 CPU: 0
[  446.893488] EIP is at iwl3945_get_channels_for_scan+0xb4/0x315 [iwl3=
945]
[  446.893494] EAX: f712a000 EBX: f0548ae0 ECX: 00000000 EDX: 00000000
[  446.893500] ESI: f05c00f2 EDI: 00000058 EBP: 00000000 ESP: f6bc5ecc
[  446.893505]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[  446.893511] Process iwl3945 (pid: 1312, ti=3Df6bc4000 task=3Df04c79c=
0
task.ti=3Df6bc4000)
[  446.893516] Stack:
[  446.893519]  00000067 f04c79ec 00000000 00000000 00000000 00210001
c10272fc c13b0401
[  446.893532] <0> c1225b2d c13b0400 f054f0f0 0002ff00 00000058
00000021 0057f0f0 f0548ae0
[  446.893546] <0> 00000000 00000005 f05c0000 f8ea1cc1 00000000
f05c00f2 00000000 c1071393
[  446.893561] Call Trace:
[  446.893572]  [<c10272fc>] ? add_preempt_count+0x8f/0x91
[  446.893581]  [<c1225b2d>] ? _raw_spin_lock_irqsave+0x1c/0x35
[  446.893598]  [<f8ea1cc1>] ? iwl3945_request_scan+0x697/0x799 [iwl394=
5]
[  446.893607]  [<c1071393>] ? perf_event_task_sched_in+0xe/0x71
[  446.893614]  [<c1225cf8>] ? _raw_spin_unlock_irq+0x1e/0x28
[  446.893631]  [<f8e62768>] ? iwl_bg_start_internal_scan+0x280/0x299 [=
iwlcore]
[  446.893639]  [<c103c530>] ? run_workqueue+0x65/0xe1
[  446.893654]  [<f8e624e8>] ? iwl_bg_start_internal_scan+0x0/0x299 [iw=
lcore]
[  446.893661]  [<c103c65b>] ? worker_thread+0xaf/0xbb
[  446.893669]  [<c103f22a>] ? autoremove_wake_function+0x0/0x29
[  446.893676]  [<c103c5ac>] ? worker_thread+0x0/0xbb
[  446.893683]  [<c103ef3f>] ? kthread+0x5f/0x64
[  446.893690]  [<c103eee0>] ? kthread+0x0/0x64
[  446.893698]  [<c10033b6>] ? kernel_thread_helper+0x6/0x10
[  446.893702] Code: 88 44 24 1c 83 e8 02 88 44 24 2d 8d 4f ff 0f b7
c7 89 44 24 30 66 89 4c 24 3a e9 ea 01 00 00 8b 54 24 10 8b 4c 24 08
8b 6c 90 20 <39> 4d 00 0f 85 d1 01 00 00 66 8b 4d 06 89 d8 88 4e 01 8b
54 24
[  446.893784] EIP: [<f8e9eb54>]
iwl3945_get_channels_for_scan+0xb4/0x315 [iwl3945] SS:ESP
0068:f6bc5ecc
[  446.893801] CR2: 0000000000000000
[  446.893812] ---[ end trace 7a6cdfd823c4f035 ]---


On Fri, May 28, 2010 at 8:09 PM, John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> Dave,
>
> Here are a few small fixes intended for 2.6.35. =C2=A0Included are a =
null
> pointer dereference fix, and a use-after-free fix, as well as some mo=
re
> minor stuff. =C2=A0It also include the revert of a earlier patch that=
 I
> inadvertantly merged out of order, effectively creating a bug rather
> than fixing one. =C2=A0The reverted patch will now be pointed at 2.6.=
36
> instead.
>
> Please let me know if there are problems!
>
> Thanks,
>
> John
>
> ---
>
> The following changes since commit 045de01a174d9f0734f657eb4b3313d89b=
4fd5ad:
> =C2=A0Scott Feldman (1):
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netlink: bug fix: wrong size was calculate=
d for vfinfo list blob
>
> are available in the git repository at:
>
> =C2=A0git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless=
-2.6.git master
>
> Christian Lamparter (1):
> =C2=A0 =C2=A0 =C2=A0ar9170usb: fix read from freed driver context
>
> Christoph Fritz (1):
> =C2=A0 =C2=A0 =C2=A0ssb: fix NULL ptr deref when pcihost_wrapper is u=
sed
>
> Johannes Berg (1):
> =C2=A0 =C2=A0 =C2=A0mac80211: make a function static
>
> John W. Linville (1):
> =C2=A0 =C2=A0 =C2=A0Revert "rt2x00: Fix rt2800usb TX descriptor writi=
ng."
>
> Justin P. Mattock (1):
> =C2=A0 =C2=A0 =C2=A0ath9k: Fix ath_print in xmit for hardware reset.
>
> Prarit Bhargava (1):
> =C2=A0 =C2=A0 =C2=A0libertas: fix uninitialized variable warning
>
> Vasanthakumar Thiagarajan (1):
> =C2=A0 =C2=A0 =C2=A0ath9k: Fix bug in the way "bf_tx_aborted" of stru=
ct ath_buf is used
>
> =C2=A0drivers/net/wireless/ath/ar9170/usb.c =C2=A0 | =C2=A0 14 ++++++=
++++++--
> =C2=A0drivers/net/wireless/ath/ath9k/xmit.c =C2=A0 | =C2=A0 =C2=A06 +=
+++--
> =C2=A0drivers/net/wireless/libertas/rx.c =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 =C2=A05 ++---
> =C2=A0drivers/net/wireless/rt2x00/rt2800usb.c | =C2=A0 =C2=A02 +-
> =C2=A0drivers/ssb/pci.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A09 ++++++---
> =C2=A0drivers/ssb/sprom.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0net/mac80211/chan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +-
> =C2=A07 files changed, 27 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ar9170/usb.c b/drivers/net/wire=
less/ath/ar9170/usb.c
> index 82ab532..a93dc18 100644
> --- a/drivers/net/wireless/ath/ar9170/usb.c
> +++ b/drivers/net/wireless/ath/ar9170/usb.c
> @@ -739,17 +739,27 @@ err_out:
> =C2=A0static void ar9170_usb_firmware_failed(struct ar9170_usb *aru)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct device *parent =3D aru->udev->dev.p=
arent;
> + =C2=A0 =C2=A0 =C2=A0 struct usb_device *udev;
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Store a copy of the usb_device pointer=
 locally.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* This is because device_release_driver =
initiates
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* ar9170_usb_disconnect, which in turn f=
rees our
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* driver context (aru).
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 udev =3D aru->udev;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0complete(&aru->firmware_loading_complete);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* unbind anything failed */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (parent)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0device_lock(pa=
rent);
> - =C2=A0 =C2=A0 =C2=A0 device_release_driver(&aru->udev->dev);
> +
> + =C2=A0 =C2=A0 =C2=A0 device_release_driver(&udev->dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (parent)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0device_unlock(=
parent);
>
> - =C2=A0 =C2=A0 =C2=A0 usb_put_dev(aru->udev);
> + =C2=A0 =C2=A0 =C2=A0 usb_put_dev(udev);
> =C2=A0}
>
> =C2=A0static void ar9170_usb_firmware_finish(const struct firmware *f=
w, void *context)
> diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wire=
less/ath/ath9k/xmit.c
> index 3db1917..859aa4a 100644
> --- a/drivers/net/wireless/ath/ath9k/xmit.c
> +++ b/drivers/net/wireless/ath/ath9k/xmit.c
> @@ -1198,7 +1198,7 @@ void ath_drain_all_txq(struct ath_softc *sc, bo=
ol retry_tx)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int r;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ath_print(comm=
on, ATH_DBG_FATAL,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 "Unable to stop TxDMA. Reset HAL!\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 "Failed to stop TX DMA. Resetting hardware!\n");
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_bh(&=
sc->sc_resetlock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0r =3D ath9k_hw=
_reset(ah, sc->sc_ah->curchan, false);
> @@ -1728,6 +1728,8 @@ static int ath_tx_setup_buffer(struct ieee80211=
_hw *hw, struct ath_buf *bf,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bf->bf_isnullf=
unc =3D false;
>
> + =C2=A0 =C2=A0 =C2=A0 bf->bf_tx_aborted =3D false;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> @@ -1989,7 +1991,7 @@ static int ath_tx_num_badfrms(struct ath_softc =
*sc, struct ath_buf *bf,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int nbad =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int isaggr =3D 0;
>
> - =C2=A0 =C2=A0 =C2=A0 if (bf->bf_tx_aborted)
> + =C2=A0 =C2=A0 =C2=A0 if (bf->bf_lastbf->bf_tx_aborted)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0isaggr =3D bf_isaggr(bf);
> diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireles=
s/libertas/rx.c
> index a115bfa..7a377f5 100644
> --- a/drivers/net/wireless/libertas/rx.c
> +++ b/drivers/net/wireless/libertas/rx.c
> @@ -329,9 +329,8 @@ static int process_rxed_802_11_packet(struct lbs_=
private *priv,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* create the exported radio header */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* radiotap header */
> - =C2=A0 =C2=A0 =C2=A0 radiotap_hdr.hdr.it_version =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 /* XXX must check this value for pad */
> - =C2=A0 =C2=A0 =C2=A0 radiotap_hdr.hdr.it_pad =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 memset(&radiotap_hdr, 0, sizeof(radiotap_hdr))=
;
> + =C2=A0 =C2=A0 =C2=A0 /* XXX must check radiotap_hdr.hdr.it_pad for =
pad */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0radiotap_hdr.hdr.it_len =3D cpu_to_le16 (s=
izeof(struct rx_radiotap_hdr));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0radiotap_hdr.hdr.it_present =3D cpu_to_le3=
2 (RX_RADIOTAP_PRESENT);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0radiotap_hdr.rate =3D convert_mv_rate_to_r=
adiotap(prxpd->rx_rate);
> diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wi=
reless/rt2x00/rt2800usb.c
> index 6991613..0f8b84b 100644
> --- a/drivers/net/wireless/rt2x00/rt2800usb.c
> +++ b/drivers/net/wireless/rt2x00/rt2800usb.c
> @@ -413,7 +413,7 @@ static void rt2800usb_write_tx_desc(struct rt2x00=
_dev *rt2x00dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rt2x00_desc_read(txi, 0, &word);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rt2x00_set_field32(&word, TXINFO_W0_USB_DM=
A_TX_PKT_LEN,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0skb->len - TXINFO_DESC_SIZE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0skb->len + TXWI_DESC_SIZE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rt2x00_set_field32(&word, TXINFO_W0_WIV,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 !test_bit(ENTRY_TXD_ENCRYPT_IV, &txdesc->flags));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rt2x00_set_field32(&word, TXINFO_W0_QSEL, =
2);
> diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
> index 989e275..6dcda86 100644
> --- a/drivers/ssb/pci.c
> +++ b/drivers/ssb/pci.c
> @@ -625,9 +625,12 @@ static int ssb_pci_sprom_get(struct ssb_bus *bus=
,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ssb_printk(KER=
N_ERR PFX "No SPROM available!\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENODEV=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> -
> - =C2=A0 =C2=A0 =C2=A0 bus->sprom_offset =3D (bus->chipco.dev->id.rev=
ision < 31) ?
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SSB_SPROM_BASE1 : =
SSB_SPROM_BASE31;
> + =C2=A0 =C2=A0 =C2=A0 if (bus->chipco.dev) { =C2=A0/* can be unavail=
ible! */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bus->sprom_offset =
=3D (bus->chipco.dev->id.revision < 31) ?
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 SSB_SPROM_BASE1 : SSB_SPROM_BASE31;
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bus->sprom_offset =
=3D SSB_SPROM_BASE1;
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0buf =3D kcalloc(SSB_SPROMSIZE_WORDS_R123, =
sizeof(u16), GFP_KERNEL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!buf)
> diff --git a/drivers/ssb/sprom.c b/drivers/ssb/sprom.c
> index 007bc3a..4f7cc8d 100644
> --- a/drivers/ssb/sprom.c
> +++ b/drivers/ssb/sprom.c
> @@ -185,6 +185,7 @@ bool ssb_is_sprom_available(struct ssb_bus *bus)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* this routine differs from specs as we d=
o not access SPROM directly
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 on PCMCIA */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (bus->bustype =3D=3D SSB_BUSTYPE_PCI &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bus->chipco.dev && =C2=A0/* can =
be unavailible! */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bus->chipco.dev->id.revision=
 >=3D 31)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return bus->ch=
ipco.capabilities & SSB_CHIPCO_CAP_SPROM;
>
> diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
> index 5d218c5..32be11e 100644
> --- a/net/mac80211/chan.c
> +++ b/net/mac80211/chan.c
> @@ -5,7 +5,7 @@
> =C2=A0#include <linux/nl80211.h>
> =C2=A0#include "ieee80211_i.h"
>
> -enum ieee80211_chan_mode
> +static enum ieee80211_chan_mode
> =C2=A0__ieee80211_get_channel_mode(struct ieee80211_local *local,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ieee80211_sub_if_data *ignore)
> =C2=A0{
> --
> John W. Linville =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0Someday the world will need a hero, and you
> linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0might be all we have. =C2=A0Be ready.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
