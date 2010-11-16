From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.37-rc2 after KVM shutdown - unregister_netdevice: waiting
 for vmtst01eth0 to become free. Usage count = 1
Date: Tue, 16 Nov 2010 10:46:52 +0100
Message-ID: <1289900812.5372.1.camel@edumazet-laptop>
References: <20101116084148.GA3781@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: KVM list <kvm@vger.kernel.org>,
	netdev list <netdev@vger.kernel.org>,
	nikola.ciprich@linuxbox.cz,
	Linux kernel list <linux-kernel@vger.kernel.org>
To: Nikola Ciprich <extmaillist@linuxbox.cz>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101116084148.GA3781@pcnci.linuxbox.cz>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 16 novembre 2010 =C3=A0 09:41 +0100, Nikola Ciprich a =C3=A9cr=
it :
> Hello,
> I just tried running KVM on 2.6.37-rc2 host, and when trying to shutd=
own guest, it
> got to unterruptible state (D) and I'm getting lots of following mess=
ages:
> [ 1269.392009] unregister_netdevice: waiting for vmtst01eth0 to becom=
e free. Usage count =3D 1
> So I just want to report..
> n.
>=20
>=20

Yep, this is a known problem, thanks !

fix is there :=20

http://patchwork.ozlabs.org/patch/71354/



