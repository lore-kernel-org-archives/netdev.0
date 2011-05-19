From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.39-rc7-git11, x86/32, failed on ppp2897'th interface,
 PERCPU:  allocation failed
Date: Thu, 19 May 2011 08:39:18 +0200
Message-ID: <1305787158.3019.12.camel@edumazet-laptop>
References: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41789 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932304Ab1ESGjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 02:39:23 -0400
Received: by wwa36 with SMTP id 36so2518640wwa.1
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 23:39:22 -0700 (PDT)
In-Reply-To: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 09:35 +0300, Denys Fedoryshchenko a =C3=A9c=
rit :
> Hi, again
>=20
>  Just tried to upgrade large NAS from 2.6.38.6 to 2.6.39-rc7-git11, a=
nd=20
>  at same time enabling ipv6 on it.
>  Got that, after ppp2897 brought up (sure it means there is other 289=
6=20
>  available, and also few ethernet vlans, around 32).
>  I am not sure it is a bug, but it looks i had free memory(the box ha=
d=20
>  8GB free), and lowmem too, also i will try to enable there 64bit ker=
nel=20
>  at evening.
>=20
>  May 17 16:00:42 194.146.155.70 kernel: [14925.897799] PERCPU:=20
>  allocation failed, size=3D2048 align=3D4, failed to allocate new chu=
nk
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898163] Pid: 24207, co=
mm:=20
>  pppd Not tainted 2.6.39-rc7-git11-build-0058 #4
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898164] Call Trace:
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898169]  [<c0335548>] =
?=20
>  printk+0x18/0x20
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898173]  [<c017ecd0>]=20
>  pcpu_alloc+0x616/0x67a
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898176]  [<c0194a80>] =
?=20
>  __kmalloc_track_caller+0x68/0xc0
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898189]  [<f8ae196c>] =
?=20
>  kzalloc+0xb/0xd [ipv6]
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898193]  [<c01320a5>] =
?=20
>  _local_bh_enable_ip.clone.6+0x18/0x71
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898195]  [<c017ed3e>]=20
>  __alloc_percpu+0xa/0xc
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898198]  [<c030aa7d>]=20
>  snmp_mib_init+0x2f/0x51
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898207]  [<f8ae2ad0>]=20
>  ipv6_add_dev+0x133/0x2a3 [ipv6]
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898209]  [<c030e12d>] =
?=20
>  ip_mc_init_dev+0x75/0x86
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898211]  [<c0309321>] =
?=20
>  devinet_sysctl_register+0x34/0x38
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898221]  [<f8ae5754>]=20
>  addrconf_notify+0x50/0x6a5 [ipv6]
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898224]  [<c0218f52>] =
?=20
>  add_uevent_var+0xa3/0xa3
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898226]  [<c0309901>] =
?=20
>  inetdev_event+0x55/0x3c0
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898230]  [<c01446f9>]=20
>  notifier_call_chain+0x26/0x48
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898232]  [<c01447a7>]=20
>  raw_notifier_call_chain+0x1a/0x1c
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898236]  [<c02c8115>]=20
>  call_netdevice_notifiers+0x44/0x4b
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898238]  [<c01320a5>] =
?=20
>  _local_bh_enable_ip.clone.6+0x18/0x71
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898240]  [<c0132106>] =
?=20
>  local_bh_enable_ip+0x8/0xa
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898242]  [<c02ca19b>]=20
>  register_netdevice+0x1fb/0x255
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898244]  [<c02ca227>]=20
>  register_netdev+0x32/0x41
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898247]  [<c021d5cf>] =
?=20
>  sprintf+0x1c/0x1e
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898249]  [<c029647a>]=20
>  ppp_ioctl+0x224/0xaea
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898252]  [<c01a35cc>] =
?=20
>  do_filp_open+0x26/0x67
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898254]  [<c0296256>] =
?=20
>  ppp_write+0x98/0x98
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898256]  [<c01a53ce>]=20
>  do_vfs_ioctl+0x45e/0x498
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898258]  [<c01a118e>] =
?=20
>  getname_flags+0x1e/0xad
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898260]  [<c019391b>] =
?=20
>  kmem_cache_free+0x14/0x83
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898262]  [<c01ab5bb>] =
?=20
>  alloc_fd+0x4e/0xba
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898265]  [<c0199465>] =
?=20
>  do_sys_open+0xdb/0xe5
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898266]  [<c019ac7b>] =
?=20
>  fput+0x13/0x155
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898268]  [<c01a4387>] =
?=20
>  do_fcntl+0x227/0x3aa
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898270]  [<c01a543b>]=20
>  sys_ioctl+0x33/0x4c
>  May 17 16:00:42 194.146.155.70 kernel: [14925.898273]  [<c0336edd>]=20
>  syscall_call+0x7/0xb
> --

Its a known problem : When ipv6 is enabled, we allocate percpu memory t=
o
hold per device snmp counters.

make sure kernel idea of max possible cpus matches real number of cpus.

And yes, switching to 64bit kernel helps a lot.



