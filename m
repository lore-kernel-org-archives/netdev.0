From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Tue, 27 Jul 2004 17:20:18 +0300 (EEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0407271710070.3787-100000@silmu.st.jyu.fi>
References: <16646.14381.740376.204381@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	H?ctor Mart?n <hector@marcansoft.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
	<netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265966AbUG0OVF@vger.kernel.org>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16646.14381.740376.204381@robur.slu.se>
List-Id: netdev.vger.kernel.org

On Tue, 27 Jul 2004, Robert Olsson wrote:

>  > First run:
>  > timestamp diff =3D 0, maxlat =3D 4581159
>  Yes you starved your user apps for ~5 sec.=20
>  Any idea where your load comes from? Pure NFS network load cannot be=
 hard.

Yeah, when the ksoftirqd is taking all the cpu it will be like that, bu=
t=20
when the kernel is behaving normally the starving diff is between 0->1s=
ec.

With two samba-server-> workstation -> nfs-server file copys on the dif=
f=20
is normally 0.02secs if I'm not doing anything else but If I will do=20
something cpu-intensive like compiling the kernel with "make -j3", the=20
ksoftirqd will be soon taking all the cpu-time but this requires that I=
=20
will also have those network file transfers going on.

--
Pasi Sj=F6holm



 =20
