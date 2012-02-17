From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH v2 2/2] adi: adapt to eth_hw_addr_random() and changes in arch/blackfin
Date: Thu, 16 Feb 2012 23:37:25 -0500
Message-ID: <CAMjpGUdAe66Nw16EyM1_dv4e8uHV02tcfqiuWL8ipeUrQ=HThg@mail.gmail.com>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de> <1329412171-20704-3-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bob Liu <bob.liu@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329412171-20704-3-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 12:09, Danny Kukawka wrote:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 netdev_warn(ndev, "Setting Ethernet MAC to a random one\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 eth_hw_addr_random(ndev);

would it make sense to have the core dump the warning ?
-mike
