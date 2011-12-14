From: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next V2 00/21] net/mlx4: SRIOV support
Date: Wed, 14 Dec 2011 12:42:13 -0800
Message-ID: <CAE9FiQU1EwcGBhn2bFksB30nb8p3FEo=vvOJYXq3hAA1ArhqWg@mail.gmail.com>
References: <4EE75CD1.7070900@mellanox.co.il>
	<20111213.141413.1872427395829102426.davem@davemloft.net>
	<953B660C027164448AE903364AC447D2485F0A86@MTLDAG02.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org" <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <953B660C027164448AE903364AC447D2485F0A86-LSMZvP3E4uyuSA5JZHE7gA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 13, 2011 at 11:16 AM, Yevgeny Petrilin
<yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>> > This is V2 of a patch set that adds SRIOV support for ConnectX2 an=
d
>> > ConnectX3 HW for Ethernet Link layer. =A0Infiniband and RoCE SRIOV
>> > support will be added at later stage
>>

got following warning:

drivers/built-in.o: In function `mlx4_en_set_pauseparam':
/home/yhlu/xx/xx/kernel/tip/linux-2.6/drivers/net/ethernet/mellanox/mlx=
4/en_ethtool.c:387:
undefined reference to `mlx4_SET_PORT_general'
drivers/built-in.o: In function `mlx4_en_do_set_multicast':
/home/yhlu/xx/xx/kernel/tip/linux-2.6/drivers/net/ethernet/mellanox/mlx=
4/en_netdev.c:233:
undefined reference to `mlx4_SET_PORT_qpn_calc'
/home/yhlu/xx/xx/kernel/tip/linux-2.6/drivers/net/ethernet/mellanox/mlx=
4/en_netdev.c:277:
undefined reference to `mlx4_SET_PORT_qpn_calc'
drivers/built-in.o: In function `mlx4_en_start_port':
/home/yhlu/xx/xx/kernel/tip/linux-2.6/drivers/net/ethernet/mellanox/mlx=
4/en_netdev.c:664:
undefined reference to `mlx4_SET_PORT_general'
/home/yhlu/xx/xx/kernel/tip/linux-2.6/drivers/net/ethernet/mellanox/mlx=
4/en_netdev.c:676:
undefined reference to `mlx4_SET_PORT_qpn_calc'
drivers/built-in.o: In function `mlx4_en_init_netdev':
/home/yhlu/xx/xx/kernel/tip/linux-2.6/drivers/net/ethernet/mellanox/mlx=
4/en_netdev.c:1138:
undefined reference to `mlx4_SET_PORT_general'
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
