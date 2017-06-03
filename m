From: Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>
Subject: Re: ath9k_htc - Division by zero in kernel (as well as firmware
 panic)
Date: Sat, 3 Jun 2017 09:57:00 +0200
Message-ID: <71818afe-9075-5582-bb6c-650dfa8a5363@rempel-privat.de>
References: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="415QJvTWQF9UvxKLl4kuEBb1CsHUx30p5"
To: Nathan Royce <nroycea+kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ath9k_htc_fw <ath9k_htc_fw-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--415QJvTWQF9UvxKLl4kuEBb1CsHUx30p5
Content-Type: multipart/mixed; boundary="qhjlQVd67XBgcXMFngbgtkFrxqBK5Ibaq";
 protected-headers="v1"
From: Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>
To: Nathan Royce <nroycea+kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
 Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 ath9k_htc_fw <ath9k_htc_fw-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Message-ID: <71818afe-9075-5582-bb6c-650dfa8a5363-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>
Subject: Re: ath9k_htc - Division by zero in kernel (as well as firmware
 panic)
References: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
In-Reply-To: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>

--qhjlQVd67XBgcXMFngbgtkFrxqBK5Ibaq
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: quoted-printable

Hi,

Am 03.06.2017 um 00:02 schrieb Nathan Royce:
> ODroid XU4
>=20
> $ uname -a
> Linux computer 4.12.0-rc3-dirty #1 SMP Wed May 31 15:02:05 CDT 2017
> armv7l GNU/Linux
>=20
> $ lsusb
> ...
> Bus 001 Device 002: ID 2109:2813 VIA Labs, Inc.
> Bus 001 Device 010: ID 0cf3:7015 Qualcomm Atheros Communications
> TP-Link TL-WN821N v3 / TL-WN822N v2 802.11n [Atheros AR7010+AR9287]
> ...
>=20
> *****
> Jun 02 16:20:11 computer hostapd[14954]: vwlan0: interface state
> COUNTRY_UPDATE->HT_SCAN
> Jun 02 16:20:17 computer hostapd[14954]: 20/40 MHz operation not
> permitted on channel pri=3D7 sec=3D3 based on overlapping BSSes
> Jun 02 16:20:18 computer kernel: Division by zero in kernel.
> Jun 02 16:20:18 computer kernel: CPU: 1 PID: 14507 Comm: kworker/u16:2
> Tainted: G        W       4.12.0-rc3-dirty #1
> Jun 02 16:20:18 computer kernel: Hardware name: SAMSUNG EXYNOS
> (Flattened Device Tree)
> Jun 02 16:20:18 computer kernel: Workqueue: phy5 ieee80211_scan_work [m=
ac80211]
> Jun 02 16:20:18 computer kernel: [<c010ee0c>] (unwind_backtrace) from
> [<c010b61c>] (show_stack+0x10/0x14)
> Jun 02 16:20:18 computer kernel: [<c010b61c>] (show_stack) from
> [<c0377708>] (dump_stack+0x88/0x9c)
> Jun 02 16:20:18 computer kernel: [<c0377708>] (dump_stack) from
> [<c03755d0>] (Ldiv0_64+0x8/0x18)
> Jun 02 16:20:18 computer kernel: [<c03755d0>] (Ldiv0_64) from
> [<bf71c9a4>] (ath9k_get_next_tbtt+0x58/0x5c [ath9k_common])

Hm... this function and file:
linux/drivers/net/wireless/ath/ath9k/common-beacon.c
didn't changed since 2015. So, it should be some thing different.
Can you run
git bisect to find exact patch caused this regression?

> Jun 02 16:20:18 computer kernel: [<bf71c9a4>] (ath9k_get_next_tbtt
> [ath9k_common]) from [<bf71cb90>] (ath9k_cmn_beacon_config
> Jun 02 16:20:18 computer kernel: [<bf71cb90>]
> (ath9k_cmn_beacon_config_ap [ath9k_common]) from [<bf7898c8>]
> (ath9k_htc_beacon
> Jun 02 16:20:18 computer kernel: [<bf7898c8>]
> (ath9k_htc_beacon_config_ap [ath9k_htc]) from [<bf7885a8>]
> (ath9k_htc_vif_recon
> Jun 02 16:20:18 computer kernel: [<bf7885a8>] (ath9k_htc_vif_reconfig
> [ath9k_htc]) from [<bf78860c>] (ath9k_htc_sw_scan_compl
> Jun 02 16:20:18 computer kernel: [<bf78860c>]
> (ath9k_htc_sw_scan_complete [ath9k_htc]) from [<bf506d38>]
> (__ieee80211_scan_co
> Jun 02 16:20:18 computer kernel: [<bf506d38>]
> (__ieee80211_scan_completed [mac80211]) from [<bf507968>]
> (ieee80211_scan_work+
> Jun 02 16:20:18 computer kernel: [<bf507968>] (ieee80211_scan_work
> [mac80211]) from [<c0133f10>] (process_one_work+0x1d8/0x40
> Jun 02 16:20:18 computer kernel: [<c0133f10>] (process_one_work) from
> [<c0134cb4>] (worker_thread+0x4c/0x564)
> Jun 02 16:20:18 computer kernel: [<c0134cb4>] (worker_thread) from
> [<c0139c20>] (kthread+0x14c/0x154)
> Jun 02 16:20:18 computer kernel: [<c0139c20>] (kthread) from
> [<c0107c38>] (ret_from_fork+0x14/0x3c)
> Jun 02 16:20:18 computer hostapd[14954]: Using interface wlan0 with
> hwaddr <sanitized> and ssid "<sanitized>"
> Jun 02 16:20:18 computer kernel: IPv6: ADDRCONF(NETDEV_CHANGE):
> vwlan0: link becomes ready
> *****
> This is a new one on me.
>=20
> The "normal" problem (search shows to be a very old issue) I
> consistently (daily or multiple times/day) encounter is:

Yes, this is "normal" problem. The firmware has no error handler for PCI
bus related exceptions. So if we filed to read PCI bus first time, we
have choice to Ooops and stall or Ooops and reboot ASAP. So we reboot
and provide an kernel "firmware panic!" message.
Every one who can or will to fix this, is welcome.

> *****
> Jun 02 14:55:30 computer kernel: usb 1-1.1: ath: firmware panic!
> exccause: 0x0000000d; pc: 0x0090ae81; badvaddr: 0x10ff4038.
> Jun 02 14:55:30 computer kernel: usb 1-1.1: USB disconnect, device numb=
er 9
> Jun 02 14:55:30 computer systemd-networkd[11959]: vwlan0: Lost carrier
> Jun 02 14:55:30 computer kernel: br0: port 2(vwlan0) entered disabled s=
tate
> Jun 02 14:55:30 computer kernel: wlan0: deauthenticating from
> <sanitized> by local choice (Reason: 3=3DDEAUTH_LEAVING)
> Jun 02 14:55:30 computer kernel: ath: phy4: Failed to wakeup in 500us
> Jun 02 14:55:30 computer kernel: ath: phy4: Failed to wakeup in 500us
> Jun 02 14:55:30 computer kernel: ath: phy4: Failed to wakeup in 500us
> Jun 02 14:55:30 computer kernel: ath: phy4: Failed to wakeup in 500us
> Jun 02 14:55:30 computer systemd-networkd[11959]: wlan0: Lost carrier
> Jun 02 14:55:30 computer systemd[1]: Stopping A simple WPA encrypted
> wireless connection using a static IP...
> -- Subject: Unit netctl-BAMkOIh1VfQc5CkaFG5UGg@public.gmane.org has begun shutting down
> -- Defined-By: systemd
> -- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel=

> --
> -- Unit netctl-BAMkOIh1VfQc5CkaFG5UGg@public.gmane.org has begun shutting down.
> Jun 02 14:55:30 computer kernel: device vwlan0 left promiscuous mode
> Jun 02 14:55:30 computer kernel: br0: port 2(vwlan0) entered disabled s=
tate
> Jun 02 14:55:30 computer audit: ANOM_PROMISCUOUS dev=3Dvwlan0 prom=3D0
> old_prom=3D256 auid=3D4294967295 uid=3D0 gid=3D0 ses=3D4294967295
> Jun 02 14:55:30 computer hostapd[13218]: vwlan0: AP-STA-DISCONNECTED <s=
anitized>
> Jun 02 14:55:30 computer hostapd[13218]: Failed to set beacon parameter=
s
> Jun 02 14:55:30 computer hostapd[13218]: vwlan0: INTERFACE-DISABLED
> Jun 02 14:55:30 computer kernel: usb 1-1.1: ath9k_htc: USB layer deinit=
ialized
> Jun 02 14:55:30 computer systemd[1]: Starting Load/Save RF Kill Switch =
Status...
> -- Subject: Unit systemd-rfkill.service has begun start-up
> -- Defined-By: systemd
> -- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel=

> --
> -- Unit systemd-rfkill.service has begun starting up.
> Jun 02 14:55:30 computer systemd[1]: Started Load/Save RF Kill Switch S=
tatus.
> -- Subject: Unit systemd-rfkill.service has finished start-up
> -- Defined-By: systemd
> -- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel=

> --
> -- Unit systemd-rfkill.service has finished starting up.
> --
> -- The start-up result is done.
> Jun 02 14:55:30 computer network[13261]: Stopping network profile 'wlan=
0'...
> Jun 02 14:55:30 computer kernel: usb 1-1.1: new high-speed USB device
> number 10 using exynos-ehci
> Jun 02 14:55:30 computer kernel: usb 1-1.1: New USB device found,
> idVendor=3D0cf3, idProduct=3D7015
> Jun 02 14:55:30 computer kernel: usb 1-1.1: New USB device strings:
> Mfr=3D16, Product=3D32, SerialNumber=3D48
> Jun 02 14:55:30 computer kernel: usb 1-1.1: Product: USB WLAN
> Jun 02 14:55:30 computer kernel: usb 1-1.1: Manufacturer: ATHEROS
> Jun 02 14:55:30 computer kernel: usb 1-1.1: SerialNumber: 12345
> Jun 02 14:55:30 computer kernel: usb 1-1.1: ath9k_htc: Firmware
> ath9k_htc/htc_7010-1.4.0.fw requested
> Jun 02 14:55:30 computer kernel: usb 1-1.1: ath9k_htc: Transferred FW:
> ath9k_htc/htc_7010-1.4.0.fw, size: 72812
> Jun 02 14:55:30 computer kernel: ath9k_htc 1-1.1:1.0: ath9k_htc: HTC
> initialized with 45 credits
> Jun 02 14:55:31 computer kernel: ath9k_htc 1-1.1:1.0: ath9k_htc: FW Ver=
sion: 1.4
> Jun 02 14:55:31 computer kernel: ath9k_htc 1-1.1:1.0: FW RMW support: O=
n
> Jun 02 14:55:31 computer kernel: ath: EEPROM regdomain: 0x809c
> Jun 02 14:55:31 computer kernel: ath: EEPROM indicates we should
> expect a country code
> Jun 02 14:55:31 computer kernel: ath: doing EEPROM country->regdmn map =
search
> Jun 02 14:55:31 computer kernel: ath: country maps to regdmn code: 0x52=

> Jun 02 14:55:31 computer kernel: ath: Country alpha2 being used: CN
> Jun 02 14:55:31 computer kernel: ath: Regpair used: 0x52
> Jun 02 14:55:31 computer kernel: ieee80211 phy5: Atheros AR9287 Rev:2
> Jun 02 14:55:31 computer kernel: IPv6: ADDRCONF(NETDEV_UP): vwlan0:
> link is not ready
> Jun 02 14:55:31 computer hostapd[13218]: vwlan0: INTERFACE-ENABLED
> Jun 02 14:55:31 computer network[13261]: Stopped network profile 'wlan0=
'
> *****
> I don't know the particular reason for this one.
> At first it would happen every time I compiled anything (all cpu
> used). Then I added the ZTE Mobley to the USB hub. Even after removing
> the Mobley, the panic would still happen often.
> I then recompiled the kernel so only the 4 LITTLE cpus were used
> (big.LITTLE support+switcher), but the panic still happens sometimes.
> Now the consistency seems to come from the wireless adapter used as
> both AP and managed client.

It is possible. If adapter is used in AP mode, then lots of WiFi noise
is dumped over this interface. I assume the reproducibility depends on
external environment, not internal.

--=20
Regards,
Oleksij


--qhjlQVd67XBgcXMFngbgtkFrxqBK5Ibaq--

--415QJvTWQF9UvxKLl4kuEBb1CsHUx30p5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iF4EAREIAAYFAlkya8wACgkQHwImuRkmbWm+FAD9GyDZZcWToZ6edZgdyH/JmGnF
Z1YjXbuWLOICr/9OYs0A/idba3qwGjOzQG9UsC4IyhAMASfpaa4CrmH9ZbmiOUkO
=wEtW
-----END PGP SIGNATURE-----

--415QJvTWQF9UvxKLl4kuEBb1CsHUx30p5--
