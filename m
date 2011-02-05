From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH 0/5] net: sysctl: share ipv4/ipv6 sysctl tables
Date: Sat, 5 Feb 2011 16:59:04 +0200
Message-ID: <AANLkTi=Wg3_Uqrb=scquU9UojEJ_R_UyYhSYK6igt5sa@mail.gmail.com>
References: <cover.1296793770.git.lucian.grijincu@gmail.com>
 <AANLkTi=3kKhWRzM7S_f18YJ=jx1P7bN9zVo9yGC7zwN_@mail.gmail.com>
 <AANLkTik=a3NmibvYM6NxvqCiSiaE0oUFNtRaqn4+g_+D@mail.gmail.com> <20110205142648.GA9814@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45557 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484Ab1BEO7Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Feb 2011 09:59:25 -0500
In-Reply-To: <20110205142648.GA9814@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 5, 2011 at 4:26 PM, Alexey Dobriyan <adobriyan@gmail.com> w=
rote:
>> I'm not sure what I have to do to pass the name of a device (e.g.
>> "eth0") instead of "default" but at least "default" and "all" work a=
nd
>> have valid dentries.
>
> You do ->parent->procname.
>
> But, but you removed parent.


To be more exact I do:
  const char *dev_name =3D filp->f_path.dentry->d_parent->d_name.name;


If the sysctl table is shared between all network devices, the last
registered node will set the ->parent.

So accessing /proc/sys/net/ipv4/conf/$DEVNAME/$CTL will access $CTL
for the last network device registered not for $DEVNAME.

--=20
=C2=A0.
=2E.: Lucian
