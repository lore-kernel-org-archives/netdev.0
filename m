From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH v2 2/2] adi: adapt to eth_hw_addr_random() and changes in arch/blackfin
Date: Fri, 17 Feb 2012 11:57:54 +0100
Message-ID: <201202171157.55585.danny.kukawka@bisect.de>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de> <1329412171-20704-3-git-send-email-danny.kukawka@bisect.de> <CAMjpGUdAe66Nw16EyM1_dv4e8uHV02tcfqiuWL8ipeUrQ=HThg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bob Liu <bob.liu@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMjpGUdAe66Nw16EyM1_dv4e8uHV02tcfqiuWL8ipeUrQ=HThg@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Freitag, 17. Februar 2012, Mike Frysinger wrote:
> On Thu, Feb 16, 2012 at 12:09, Danny Kukawka wrote:
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 netdev_warn(ndev, "Setting Ethernet MAC to a
> > random one\n"); + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 eth_hw_addr_random(ndev);
>
> would it make sense to have the core dump the warning ?

Maybe. Many drivers already print information about setting a random ma=
c=20
address to a netdevice. Some with printk, some via=20
netdev_warn/netdev_info/netdev_dbg or netif_dbg and other with costum=20
methods. I could unify this, in a next step with a netdev_info in=20
eth_hw_addr_random(), if it's okay for David.=20

Danny
