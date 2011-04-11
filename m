From: Eric B Munson <emunson@mgebm.net>
Subject: Re: 2.6.39-rc2 boot crash
Date: Mon, 11 Apr 2011 17:07:47 -0400
Message-ID: <20110411210746.GA2453@mgebm.net>
References: <20110406184753.GA7691@mgebm.net>
 <1302115953.8094.217.camel@nimitz>
 <20110406212041.GA2596@mgebm.net>
 <20110406.142157.68145422.davem@davemloft.net>
 <20110406220512.GA2460@mgebm.net>
 <4D9D9AA4.6060304@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
Cc: David Miller <davem@davemloft.net>, dave@linux.vnet.ibm.com,
	linux-kernel@vger.kernel.org, zbr@ioremap.net, gregkh@suse.de,
	ksrinivasan@novell.com, NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D9D9AA4.6060304@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 07 Apr 2011, Patrick McHardy wrote:

> Am 07.04.2011 00:05, schrieb Eric B Munson:
> > On Wed, 06 Apr 2011, David Miller wrote:
> >=20
> >> From: Eric B Munson <emunson@mgebm.net>
> >> Date: Wed, 6 Apr 2011 17:20:41 -0400
> >>
> >>> A bisect points at commit 04f482faf50535229a5a5c8d629cf963899f857c fo=
r the
> >>> first bad one.  Unfortunately, I have not made netconsole work yet an=
d the
> >>> hang is happening mostly right when X starts so I can't even see the =
console.
> >>> I will keep at the netconsole and see if I can get it functioning, al=
so I will
> >>> try to boot this kernel in a VM and see if that helps.
> >>
> >> Patrick, please help Eric so we can fix this bug.
> >>
> >> Thanks.
> >>
> >=20
> > I have a useful trace now from netconsole:
> >=20
> > [   18.029521] BUG: sleeping function called from invalid context at ar=
ch/x86/mm/fault.c:1087
> > [   18.029527] in_atomic(): 0, irqs_disabled(): 1, pid: 2018, name: cgr=
ulesengd
> > [   18.029693] BUG: unable to handle kernel paging request at 000010000=
0000000
> > [   18.029730] IP: [<ffffffff814c3db8>] __skb_recv_datagram+0x128/0x2b0
> > [   18.029756] PGD 0=20
> > [   18.029768] Oops: 0002 [#1] SMP=20
> > [   18.029790] last sysfs file: /sys/devices/pci0000:00/0000:00:02.0/00=
00:02:00.0/usb10/10-0:1.0/bInterfaceClass
> > [   18.029824] CPU 0=20
> > [   18.029833] Modules linked in: kvm_intel kvm parport_pc ppdev snd_hd=
a_codec_hdmi snd_hda_codec_realtek nfs lockd fscache auth_rpcgss nfs_acl su=
nrpc radeon deflate zlib_deflate ctr twofish_generic twofish_x86_64 twofish=
_common ttm camellia serpent drm_kms_helper snd_usb_audio blowfish cast5 sn=
d_hda_intel drm des_generic snd_hda_codec snd_hwdep aesni_intel snd_usbmidi=
_lib cryptd aes_x86_64 aes_generic snd_pcm xcbc snd_seq_midi rmd160 snd_raw=
midi sha512_generic sha256_generic uvcvideo snd_seq_midi_event sha1_generic=
 snd_seq snd_timer crypto_null snd_seq_device snd af_key xhci_hcd i7core_ed=
ac videodev joydev psmouse edac_core v4l2_compat_ioctl32 w83627ehf soundcor=
e serio_raw hwmon_vid snd_page_alloc max6650 hid_microsoft i2c_algo_bit lp =
parport asus_atk0110 usbhid hid firewire_ohci firewire_core crc_itu_t
> > [   18.030424]=20
> > [   18.030432] Pid: 2018, comm: cgrulesengd Not tainted 2.6.39-rc2+ #52=
 System manufacturer System Product Name/P6X58D PREMIUM
> > [   18.030477] RIP: 0010:[<ffffffff814c3db8>]  [<ffffffff814c3db8>] __s=
kb_recv_datagram+0x128/0x2b0
> >...
> >=20
> > I haven't dug into it at all, but I am happy to help test potential fix=
es.
>=20
> I can't figure this out, the only thing that should have changed is the
> time the initial PROC_CN_MCAST_LISTEN message is received. Apparently
> at that point connector is not fully initialized yet. Please post your
> config and the full boot log. Thanks.
>=20

I am still seeing this on Linus' tree, is there anything more I can do to h=
elp
track the problem?

Thanks,
Eric

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNo22iAAoJEH65iIruGRnNZdYH/AnYjXgGDm8nKzAWvoXi0ak+
ODuWMYda6VngeavBNeqWSnbK81pO9KtR5taooQGrUDxw71NDH6H/eV5ULnEFMU3v
KvvM1ZyOs4zj9TpOR1R6xw5Z4l1o64iJoojbEIy1EFIm+JSn/3KqFAiEaNuJleeq
b990zGnECwekk5hppAJfzZrInW8N/gXO94kck4MTXmCAkTsH+8JqyFxyc3LtIrEs
nn1hihUAXH6waxvJoeAdjfL090gRwKMA9aMadMqHo9w26Yz1710o+qIV1y1NqIXu
lEKPCcsmBhfI/IM5vqMsZ3uNpZlqz5Xy4YPzImjrT5trBHvoFGVRDe5ANmiUKD8=
=MEdp
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--
