From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: d80211: How does TX flow control work?
Date: Sun, 07 Jan 2007 01:00:37 +0100
Message-ID: <45A03825.9080807@web.de>
References: <459A5945.80909@web.de>	<20070103185203.2754e059@griffin.suse.cz>	<459BF179.6000906@web.de> <20070103191853.4f440b8b@griffin.suse.cz> <459BFB05.9040608@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD20295A4912E18437963F486"
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:41996 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272AbXAGAAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 19:00:42 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <459BFB05.9040608@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD20295A4912E18437963F486
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Jan Kiszka wrote:
> Jiri Benc wrote:
>> On Wed, 03 Jan 2007 19:10:01 +0100, Jan Kiszka wrote:
>>> BUG: warning at /usr/src/rt2x00/rt2x00/ieee80211/ieee80211.c:1256/iee=
e80211_tx()
>>>  <cfa02245> ieee80211_master_start_xmit+0x105/0x430 [80211]  <c024e35=
d> __ip_ct_refresh_acct+0x4d/0x60
>>>  <c024fd11> tcp_packet+0x941/0x970  <c0217442> qdisc_restart+0x92/0x1=
00
>>>  <c020d43d> dev_queue_xmit+0xbd/0x1a0  <cfa050d8> ieee80211_subif_sta=
rt_xmit+0x468/0x480 [80211]
>>>  <c0207dca> skb_clone+0x3a/0x1a0  <c021d16d> nf_hook_slow+0x4d/0xc0
>>>  <c020d495> dev_queue_xmit+0x115/0x1a0  <c0226a63> ip_output+0x1c3/0x=
200
>>>  <c0225740> ip_finish_output+0x0/0x180  <c022628b> ip_queue_xmit+0x36=
b/0x3b0
>>>  <c0224130> dst_output+0x0/0x10  <ce9bae7d> usb_hcd_giveback_urb+0x2d=
/0x60 [usbcore]
>>>  <c0237da2> tcp_v4_send_check+0x82/0xd0  <c0237da2> tcp_v4_send_check=
+0x82/0xd0
>>>  <c0233244> tcp_transmit_skb+0x5e4/0x610  <c0234b36> __tcp_push_pendi=
ng_frames+0x676/0x740
>>>  <c0207f81> __alloc_skb+0x51/0x100  <c022b817> tcp_sendmsg+0x897/0x98=
0
>>>  <c0153fa9> core_sys_select+0x1b9/0x2b0  <c0241f1d> inet_sendmsg+0x3d=
/0x50
>>>  <c0202a8f> do_sock_write+0x8f/0xa0  <c020301f> sock_aio_write+0x5f/0=
x70
>>>  <c01443d3> do_sync_write+0xc3/0x100  <c01247f0> autoremove_wake_func=
tion+0x0/0x40
>>>  <c0144ca1> vfs_write+0xa1/0x140  <c01451d3> sys_write+0x43/0x70
>>>  <c0102ae7> syscall_call+0x7/0xb
>>>
>>> Does it tell you anything already? Is there something I may instrumen=
t? What
>>> could the driver do wrong to trigger such bug?
>> Do you have CONFIG_NET_SCHED enabled?
>>

Sorry, this was most probably false alarm for the official stack. The
problem now appears to be related to a patch against d80211 that is only
present in the rt2x00 CVS.

Jan


--------------enigD20295A4912E18437963F486
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFFoDglniDOoMHTA+kRAvZSAJ9QUlaY0aM87JQaOJP7HYjQdSIUvgCfcPCa
nTFz6jSyUSs1/WMXBd3+JWg=
=Jm91
-----END PGP SIGNATURE-----

--------------enigD20295A4912E18437963F486--
