From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3] net: af_packet: Untangle packet_snd by
 adding vpacket_snd
Date: Fri, 13 May 2011 07:11:02 +0200
Message-ID: <1305263462.2831.11.camel@edumazet-laptop>
References: <20110512.175959.1343349350164758016.davem@davemloft.net>
	 <b174c9df4b7c39b4e951f1f309a4fd9086179c3c.1305242549.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b174c9df4b7c39b4e951f1f309a4fd9086179c3c.1305242549.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 12 mai 2011 =C3=A0 16:25 -0700, Joe Perches a =C3=A9crit :
> The current packet_snd handles both vlan and non-vlan frames
> with initialization of a struct virtio_net_hdr that is unused
> by non-vlan frames.
>=20
> Create a new vpacket_snd that uses this virtio_net_hdr and
> remove it and the vlan and gso logic from packet_snd.
>=20

1) I find this kind of patches a real pain, frankly.

When I have to look around code and commits to find bugs and bugs
origins, I'll have to fully check this kind of patch, and this slow dow=
n
the process a _lot_, because I have no idea if "Joe Perches" actually
tested the patch, or if its yet another "code beautifier" process in th=
e
wild.

You should have shooted when/before commit bfd5f4a3 (packet: Add
GSO/csum offload support) was accepted.

2) You did not CCed Sridhar Samudrala <sri@us.ibm.com>, the author of
above commit. I dont think David will take the time to test your patch.

3) You add some non codingstyle artifacts. I am afraid it makes me
nervous for patches bringing no real values but shuffling the code and
making maintainers life more difficult.
