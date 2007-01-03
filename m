From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: d80211: How does TX flow control work?
Date: Wed, 03 Jan 2007 19:50:45 +0100
Message-ID: <459BFB05.9040608@web.de>
References: <459A5945.80909@web.de>	<20070103185203.2754e059@griffin.suse.cz>	<459BF179.6000906@web.de> <20070103191853.4f440b8b@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC646E86CA7C31A1281D07698"
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:61219 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbXACSut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 13:50:49 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20070103191853.4f440b8b@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC646E86CA7C31A1281D07698
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Jiri Benc wrote:
> On Wed, 03 Jan 2007 19:10:01 +0100, Jan Kiszka wrote:
>> BUG: warning at /usr/src/rt2x00/rt2x00/ieee80211/ieee80211.c:1256/ieee=
80211_tx()
>>  <cfa02245> ieee80211_master_start_xmit+0x105/0x430 [80211]  <c024e35d=
> __ip_ct_refresh_acct+0x4d/0x60
>>  <c024fd11> tcp_packet+0x941/0x970  <c0217442> qdisc_restart+0x92/0x10=
0
>>  <c020d43d> dev_queue_xmit+0xbd/0x1a0  <cfa050d8> ieee80211_subif_star=
t_xmit+0x468/0x480 [80211]
>>  <c0207dca> skb_clone+0x3a/0x1a0  <c021d16d> nf_hook_slow+0x4d/0xc0
>>  <c020d495> dev_queue_xmit+0x115/0x1a0  <c0226a63> ip_output+0x1c3/0x2=
00
>>  <c0225740> ip_finish_output+0x0/0x180  <c022628b> ip_queue_xmit+0x36b=
/0x3b0
>>  <c0224130> dst_output+0x0/0x10  <ce9bae7d> usb_hcd_giveback_urb+0x2d/=
0x60 [usbcore]
>>  <c0237da2> tcp_v4_send_check+0x82/0xd0  <c0237da2> tcp_v4_send_check+=
0x82/0xd0
>>  <c0233244> tcp_transmit_skb+0x5e4/0x610  <c0234b36> __tcp_push_pendin=
g_frames+0x676/0x740
>>  <c0207f81> __alloc_skb+0x51/0x100  <c022b817> tcp_sendmsg+0x897/0x980=

>>  <c0153fa9> core_sys_select+0x1b9/0x2b0  <c0241f1d> inet_sendmsg+0x3d/=
0x50
>>  <c0202a8f> do_sock_write+0x8f/0xa0  <c020301f> sock_aio_write+0x5f/0x=
70
>>  <c01443d3> do_sync_write+0xc3/0x100  <c01247f0> autoremove_wake_funct=
ion+0x0/0x40
>>  <c0144ca1> vfs_write+0xa1/0x140  <c01451d3> sys_write+0x43/0x70
>>  <c0102ae7> syscall_call+0x7/0xb
>>
>> Does it tell you anything already? Is there something I may instrument=
? What
>> could the driver do wrong to trigger such bug?
>=20
> Do you have CONFIG_NET_SCHED enabled?
>=20

Yes. Would it make a difference /wrt to that warning when I switch it off=
?

Jan


--------------enigC646E86CA7C31A1281D07698
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFFm/sGniDOoMHTA+kRAmQ2AJ9wU60yOnC5Wgm2G8z9B91X1nhaLwCfXW9l
a1tiZqiAna5CW3CgTwJlHh4=
=jM+E
-----END PGP SIGNATURE-----

--------------enigC646E86CA7C31A1281D07698--
