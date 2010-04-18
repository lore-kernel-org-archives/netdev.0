From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#577640: linux-image-2.6.33-2-amd64: Kernel warnings in
 netns thread
Date: Sun, 18 Apr 2010 18:33:25 +0100
Message-ID: <1271612005.3679.248.camel@localhost>
References: <20100413112017.8505.36380.reportbug@japot.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-rWvstrAH0LFbnoRb/H2e"
Cc: netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Martin Ferrari <martin.ferrari@gmail.com>, 577640@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55438 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751442Ab0DRRdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 13:33:42 -0400
In-Reply-To: <20100413112017.8505.36380.reportbug@japot.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rWvstrAH0LFbnoRb/H2e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-04-13 at 13:20 +0200, Martin Ferrari wrote:
> Package: linux-2.6
> Version: 2.6.33-1~experimental.4
> Severity: normal
> Tags: experimental
>=20
> Firstly, please note that I'm running this inside a Qemu, but I
> imagine that it should not change things much.
>=20
> I installed 2.6.33 to try out the new improvements regarding network
> namespaces, and while creating and killing hundreds of them, I got
> many warnings from the kernel that might indicate a bug somewhere.
> Please see the log already included by reportbug.

I'm forwarding this to the upstream maintainers.

Ben.

[...]
> [ 6696.035331] ------------[ cut here ]------------
> [ 6696.035334] WARNING: at /build/mattems-linux-2.6_2.6.33-1~experimental=
.4-amd64-ieqSsa/linux-2.6-2.6.33-1~experimental.4/debian/build/source_amd64=
_none/kernel/sysctl.c:1894 unregister_sysctl_table+0xa6/0xd1()
> [ 6696.035336] Hardware name:=20
> [ 6696.035337] Modules linked in: veth loop parport_pc parport snd_pcm tp=
m_tis evdev snd_timer i2c_piix4 tpm tpm_bios button processor serio_raw i2c=
_core snd soundcore snd_page_alloc pcspkr psmouse ext3 jbd mbcache sg sr_mo=
d cdrom sd_mod crc_t10dif ata_generic ata_piix libata floppy 8139cp thermal=
 thermal_sys 8139too mii scsi_mod [last unloaded: veth]
> [ 6696.035354] Pid: 9, comm: netns Tainted: G        W  2.6.33-2-amd64 #1
> [ 6696.035355] Call Trace:
> [ 6696.035357]  [<ffffffff8104e303>] ? unregister_sysctl_table+0xa6/0xd1
> [ 6696.035360]  [<ffffffff8104e303>] ? unregister_sysctl_table+0xa6/0xd1
> [ 6696.035362]  [<ffffffff81046b81>] ? warn_slowpath_common+0x77/0xa3
> [ 6696.035364]  [<ffffffff8104e303>] ? unregister_sysctl_table+0xa6/0xd1
> [ 6696.035367]  [<ffffffff812b1205>] ? addrconf_ifdown+0x26f/0x2cc
> [ 6696.035369]  [<ffffffff81247edc>] ? neigh_sysctl_unregister+0x1a/0x31
> [ 6696.035371]  [<ffffffff812b1211>] ? addrconf_ifdown+0x27b/0x2cc
> [ 6696.035374]  [<ffffffff812b2b0c>] ? addrconf_notify+0x714/0x7ea
> [ 6696.035376]  [<ffffffff811eb2e7>] ? extract_entropy+0x6a/0x125
> [ 6696.035379]  [<ffffffff81053aaf>] ? lock_timer_base+0x26/0x4b
> [ 6696.035382]  [<ffffffff8123951c>] ? skb_dequeue+0x50/0x58
> [ 6696.035384]  [<ffffffff812482c8>] ? pneigh_queue_purge+0x25/0x2f
> [ 6696.035386]  [<ffffffff81249a91>] ? neigh_ifdown+0xba/0xc9
> [ 6696.035389]  [<ffffffff81062f6d>] ? notifier_call_chain+0x29/0x4c
> [ 6696.035392]  [<ffffffff81243662>] ? rollback_registered_many+0xed/0x19=
c
> [ 6696.035394]  [<ffffffff8124371f>] ? unregister_netdevice_many+0xe/0x57
> [ 6696.035397]  [<ffffffff812438a3>] ? default_device_exit_batch+0x92/0xa=
3
> [ 6696.035399]  [<ffffffff8123e97a>] ? cleanup_net+0xfd/0x1af
> [ 6696.035402]  [<ffffffff8105bd0d>] ? worker_thread+0x188/0x21d
> [ 6696.035404]  [<ffffffff8123e87d>] ? cleanup_net+0x0/0x1af
> [ 6696.035406]  [<ffffffff8105f2d2>] ? autoremove_wake_function+0x0/0x2e
> [ 6696.035409]  [<ffffffff8105bb85>] ? worker_thread+0x0/0x21d
> [ 6696.035411]  [<ffffffff8105ee99>] ? kthread+0x79/0x81
> [ 6696.035414]  [<ffffffff810098e4>] ? kernel_thread_helper+0x4/0x10
> [ 6696.035416]  [<ffffffff8105ee20>] ? kthread+0x0/0x81
> [ 6696.035418]  [<ffffffff810098e0>] ? kernel_thread_helper+0x0/0x10
> [ 6696.035419] ---[ end trace ef7b93cb006e989e ]---
[...]

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-rWvstrAH0LFbnoRb/H2e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS8tCYOe/yOyVhhEJAQJerA/+NRfPcFSytTkMQD4shWtNqEA6u36oVDvV
yY77mmLfZ1HiR3YjQ3bjffQu5gcnd7nGCtpYICKVicCzBIN39vnauLFWgNlfduLk
6oQ9NFQG41HUFqi+wV+Npa7EVbVk3HUzKMkSSrev21eS4TIFKpjBnn/QivtIl1Mp
s+ujGFhnga0RAJHuHsnqxKNWHZw1JhKwBBoGzRp2x9GKoE8SHulggr6spgSRxblX
8XhIstcadYAfkVEv8tlAoCGVxRBpZdtYVNEaPpIchbwJ49OrNvTCgb1GAHHepLbj
Ls6ekeh440T9QWxBt037a+h4f/DsRSJ43pnDmTTxRD9k+8aROrh826M1PnVSlD8t
VrxveoGT/YWGXraA0gou23wHacJhGUsqPU6eLSkAca+IgtE+K2Meidy7enfLwiz+
cJXTm2pgtJVIdyuyK/qEdB5jKhsl9joch1lmzRX6UzWuQOl8b2DKIOJGmDuprPAk
ep36Ouk8gAw2wX0lS2tZi7KRQy/uA63ncH7eV6oQvk72M8kHkjDHNTyGA6qpZbPB
3Zn2UKOPDn6zEU0nNSxzF/xV0ObdOZyeAIpMWuLK96z+kiokhE/lkoXhEFtSdDqz
EEuxN8sKeTR/IfgunCV+a4O8dTnRazwIkcGpeGwcrMpxTP7f6RwKYL3/nEPxjdIz
6k8Qxq0j3Ag=
=N7NR
-----END PGP SIGNATURE-----

--=-rWvstrAH0LFbnoRb/H2e--
