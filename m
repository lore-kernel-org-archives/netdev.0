From: Markus Suvanto <markus.suvanto@gmail.com>
Subject: WARNING: at net/ipv4/tcp.c:1186
Date: Wed, 4 Nov 2009 16:48:16 +0200
Message-ID: <bcf98daa0911040648p207ed266r1ccd38fbd1bab50e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:44537 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756613AbZKDOsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 09:48:11 -0500
Received: by yxe17 with SMTP id 17so6381105yxe.33
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 06:48:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.32-rc6 dmesg is full of warnings...


------------[ cut here ]------------
WARNING: at net/ipv4/tcp.c:1186 0xffffffff8121c0cf()
Hardware name: System Product Name
Modules linked in: tun bitrev kvm_amd kvm option usbserial ipv6
snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device
snd_pcm_o
_oss libafs(P) af_packet bridge stp llc btrfs zlib_deflate cryptomgr
aead pcompress crypto_blkcipher crc32c libcrc32c crypto_hash
crypto_alga
usedev usbhid usbmouse dvb_usb_dib0700 dib7000p dib7000m dib0070
dvb_usb dib3000mc dib8000 dibx000_common dvb_core usb_storage radeon
ttm snd
tihdmi drm_kms_helper ata_generic drm snd_hda_codec_via firmware_class
firewire_ohci i2c_piix4 i2c_algo_bit firewire_core crc_itu_t psmouse p
_hda_intel snd_hda_codec rtc_cmos snd_pcm rtc_core ehci_hcd uhci_hcd
ohci1394 ohci_hcd cfbcopyarea atkbd snd_timer atl1e snd usbcore pcspkr
s
0_pnp soundcore evdev 8250 cfbimgblt floppy ieee1394 i2c_core
processor rtc_lib thermal pata_atiixp serial_core snd_page_alloc
cfbfillrect bu
_sys asus_atk0110 nls_base sg hwmon unix ext4 jbd2 crc16 dm_mod raid1
md_mod sd_mod ahci libata scsi_mod fbcon tileblit crc32 font bitblit
so
Pid: 12653, comm: vdr Tainted: P        W  2.6.32-rc6-00572-gb419148 #23
Call Trace:
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff81044424>] ? 0xffffffff81044424
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff8121ca56>] ? 0xffffffff8121ca56
 [<ffffffff8105dc59>] ? 0xffffffff8105dc59
 [<ffffffff8105dd72>] ? 0xffffffff8105dd72
 [<ffffffff811e1d90>] ? 0xffffffff811e1d90
 [<ffffffff811dfdc5>] ? 0xffffffff811dfdc5
 [<ffffffff8105a790>] ? 0xffffffff8105a790
 [<ffffffff81067af2>] ? 0xffffffff81067af2
 [<ffffffff810699d7>] ? 0xffffffff810699d7
 [<ffffffff8100bece>] ? 0xffffffff8100bece
 [<ffffffff811e1207>] ? 0xffffffff811e1207
 [<ffffffff811df502>] ? 0xffffffff811df502
 [<ffffffff811e12c8>] ? 0xffffffff811e12c8
 [<ffffffff81025440>] ? 0xffffffff81025440
 [<ffffffff81038a48>] ? 0xffffffff81038a48
 [<ffffffff81264004>] ? 0xffffffff81264004
 [<ffffffff8100b2eb>] ? 0xffffffff8100b2eb
---[ end trace d816ed2b263fe303 ]---
recvmsg bug: copied 2AFC272F seq 30B09D30
------------[ cut here ]------------
WARNING: at net/ipv4/tcp.c:1186 0xffffffff8121c0cf()
Hardware name: System Product Name
Modules linked in: tun bitrev kvm_amd kvm option usbserial ipv6
snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device
snd_pcm_o
_oss libafs(P) af_packet bridge stp llc btrfs zlib_deflate cryptomgr
aead pcompress crypto_blkcipher crc32c libcrc32c crypto_hash
crypto_alga
usedev usbhid usbmouse dvb_usb_dib0700 dib7000p dib7000m dib0070
dvb_usb dib3000mc dib8000 dibx000_common dvb_core usb_storage radeon
ttm snd
tihdmi drm_kms_helper ata_generic drm snd_hda_codec_via firmware_class
firewire_ohci i2c_piix4 i2c_algo_bit firewire_core crc_itu_t psmouse p
_hda_intel snd_hda_codec rtc_cmos snd_pcm rtc_core ehci_hcd uhci_hcd
ohci1394 ohci_hcd cfbcopyarea atkbd snd_timer atl1e snd usbcore pcspkr
s
0_pnp soundcore evdev 8250 cfbimgblt floppy ieee1394 i2c_core
processor rtc_lib thermal pata_atiixp serial_core snd_page_alloc
cfbfillrect bu
_sys asus_atk0110 nls_base sg hwmon unix ext4 jbd2 crc16 dm_mod raid1
md_mod sd_mod ahci libata scsi_mod fbcon tileblit crc32 font bitblit
so
Pid: 12643, comm: vdr Tainted: P        W  2.6.32-rc6-00572-gb419148 #23
Call Trace:
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff81044424>] ? 0xffffffff81044424
 [<ffffffff8105a790>] ? 0xffffffff8105a790
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff8121ca56>] ? 0xffffffff8121ca56
 [<ffffffff811e1d90>] ? 0xffffffff811e1d90
7000p dib7000m dib0070 dvb_usb dib3000mc dib8000 dibx000_common
dvb_core usb_storage radeon ttm snd_hda_codec_atihdmi drm_kms_helper
ata_generic drm snd_hda_codec_via firmware_class firewire_ohci
i2c_piix4 i2c_algo_bit firewire_core crc_itu_t psmouse pata_acpi
snd_hda_intel snd_hda_codec rtc_cmos snd_pcm rtc_core ehci_hcd
uhci_hcd ohci1394 ohci_hcd cfbcopyarea atkbd snd_timer atl1e snd
usbcore pcspkr serio_raw 8250_pnp soundcore evdev 8250 cfbimgblt
floppy ieee1394 i2c_core processor rtc_lib thermal pata_atiixp
serial_core snd_page_alloc cfbfillrect button thermal_sys asus_atk0110
nls_base sg hwmon unix ext4 jbd2 crc16 dm_mod raid1 md_mod sd_mod ahci
libata scsi_mod fbcon tileblit crc32 font bitblit softcursor fb
Pid: 12643, comm: vdr Tainted: P        W  2.6.32-rc6-00572-gb419148 #23
Call Trace:
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff81044424>] ? 0xffffffff81044424
 [<ffffffff8105a790>] ? 0xffffffff8105a790
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff8121ca56>] ? 0xffffffff8121ca56
 [<ffffffff811e1d90>] ? 0xffffffff811e1d90
 [<ffffffff811dec62>] ? 0xffffffff811dec62
 [<ffffffff810c72db>] ? 0xffffffff810c72db
 [<ffffffff8105a790>] ? 0xffffffff8105a790
 [<ffffffff8103ddba>] ? 0xffffffff8103ddba
 [<ffffffff81264184>] ? 0xffffffff81264184
 [<ffffffff81062059>] ? 0xffffffff81062059
 [<ffffffff810c808e>] ? 0xffffffff810c808e
 [<ffffffff810c81a3>] ? 0xffffffff810c81a3
 [<ffffffff8100b2eb>] ? 0xffffffff8100b2eb
---[ end trace d816ed2b263fe304 ]---
recvmsg bug: copied 2AFC272F seq 30B09D30
------------[ cut here ]------------
WARNING: at net/ipv4/tcp.c:1186 0xffffffff8121c0cf()
Hardware name: System Product Name
Modules linked in: tun bitrev kvm_amd kvm option usbserial ipv6
snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device
snd_pcm_oss snd_mixer_oss libafs(P) af_packet bridge stp llc btrfs
zlib_deflate cryptomgr aead pcompress crypto_blkcipher crc32c
libcrc32c crypto_hash crypto_algapi mt2060 mousedev usbhid usbmouse
dvb_usb_dib0700 dib7000p dib7000m dib0070 dvb_usb dib3000mc dib8000
dibx000_common dvb_core usb_storage radeon ttm snd_hda_codec_atihdmi
drm_kms_helper ata_generic drm snd_hda_codec_via firmware_class
firewire_ohci i2c_piix4 i2c_algo_bit firewire_core crc_itu_t psmouse
pata_acpi snd_hda_intel snd_hda_codec rtc_cmos snd_pcm rtc_core
ehci_hcd uhci_hcd ohci1394 ohci_hcd cfbcopyarea atkbd snd_timer atl1e
snd usbcore pcspkr serio_raw 8250_pnp soundcore evdev 8250 cfbimgblt
floppy ieee1394 i2c_core processor rtc_lib thermal pata_atiixp
serial_core snd_page_alloc cfbfillrect button thermal_sys asus_atk0110
nls_base sg hwmon unix ext4 jbd2 crc16 dm_mod raid1 md_mod sd_mod ahci
libata scsi_mod fbcon tileblit crc32 font bitblit softcursor fb
Pid: 12643, comm: vdr Tainted: P        W  2.6.32-rc6-00572-gb419148 #23
Call Trace:
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff81044424>] ? 0xffffffff81044424
 [<ffffffff810d8700>] ? 0xffffffff810d8700
 [<ffffffff8121c0cf>] ? 0xffffffff8121c0cf
 [<ffffffff8121ca56>] ? 0xffffffff8121ca56
 [<ffffffff811e1d90>] ? 0xffffffff811e1d90
 [<ffffffff811dec62>] ? 0xffffffff811dec62
 [<ffffffff810c72db>] ? 0xffffffff810c72db
 [<ffffffff8105a790>] ? 0xffffffff8105a790
 [<ffffffff8103ddba>] ? 0xffffffff8103ddba
 [<ffffffff81264184>] ? 0xffffffff81264184
 [<ffffffff81062059>] ? 0xffffffff81062059
 [<ffffffff810c808e>] ? 0xffffffff810c808e
 [<ffffffff810c81a3>] ? 0xffffffff810c81a3
 [<ffffffff8100b2eb>] ? 0xffffffff8100b2eb
---[ end trace d816ed2b263fe305 ]---




2.6.32-rc6-00572-gb419148 #23 SMP Tue Nov 3 23:02:32 EET 2009 x86_
64 AMD Phenom(tm) II X3 705e Processor AuthenticAMD GNU/Linux

Gnu C                  4.3.4
Gnu make               3.81
binutils               2.18
util-linux             /usr/src/linux-2.6/scripts/ver_linux: line 23:
fdformat: command n
ot found
mount                  support
module-init-tools      found
Linux C Library        2.9
Dynamic linker (ldd)   2.9
Procps                 3.2.8
Kbd                    1.13
Sh-utils               7.5
Modules Loaded         tun bitrev kvm_amd kvm option usbserial ipv6
snd_seq_dummy snd_seq
_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss
snd_mixer_oss libafs af_packet
 bridge stp llc btrfs zlib_deflate cryptomgr aead pcompress
crypto_blkcipher crc32c libcr
c32c crypto_hash crypto_algapi mt2060 mousedev usbhid usbmouse
dvb_usb_dib0700 dib7000p d
ib7000m dib0070 dvb_usb dib3000mc dib8000 dibx000_common dvb_core
usb_storage radeon ttm
snd_hda_codec_atihdmi drm_kms_helper ata_generic drm snd_hda_codec_via
firmware_class fir
ewire_ohci i2c_piix4 i2c_algo_bit firewire_core crc_itu_t psmouse
pata_acpi snd_hda_intel
 snd_hda_codec rtc_cmos snd_pcm rtc_core ehci_hcd uhci_hcd ohci1394
ohci_hcd cfbcopyarea
atkbd snd_timer atl1e snd usbcore pcspkr serio_raw 8250_pnp soundcore
evdev 8250 cfbimgbl
t floppy ieee1394 i2c_core processor rtc_lib thermal pata_atiixp
serial_core snd_page_all
oc cfbfillrect button thermal_sys asus_atk0110 nls_base sg hwmon unix
ext4 jbd2 crc16 dm_
mod raid1 md_mod sd_mod ahci libata scsi_mod fbcon tileblit crc32 font
bitblit softcursor
 fb
