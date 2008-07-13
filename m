From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: REDIRECT in nat OUTPUT
Date: Sun, 13 Jul 2008 18:12:36 +0300
Message-ID: <200807131812.36327.denys@visp.net.lb>
References: <200807120424.56462.denys@visp.net.lb> <200807131719.50777.denys@visp.net.lb> <Pine.LNX.4.64.0807131656500.4816@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0807131656500.4816@bizon.gios.gov.pl>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 13 July 2008, Krzysztof Oledzki wrote:
> > No, seems it has performance issues without redirect(and conntrack =
unloaded too) even, iperf results on loopback is very unstable.
> >
> > Actually i dont understand, how on idle machine with Xeon processor=
 iperf over loopback (tcp) can be ~100Mbps?
> > I think it is a bug.
>=20
> Something is wrong here as:
>=20
> root@fw2-t:~# iperf -c 127.1
> ------------------------------------------------------------
> Client connecting to 127.1, TCP port 5001
> TCP window size: 49.2 KByte (default)
> ------------------------------------------------------------
> [  3] local 127.0.0.1 port 36419 connected with 127.0.0.1 port 5001
> [  3]  0.0-10.0 sec  7.10 GBytes  6.10 Gbits/sec
>=20
> # uname -r
> 2.6.24.7-o4
>=20
> # grep "model name" /proc/cpuinfo|uniq
> model name      : Intel(R) Xeon(R) CPU           X5460  @ 3.16GHz
>=20
> Best regards,
>=20
>  			Krzysztof Ol=C4=99dzki
Probably we have to do .config diff, cause i can catch instability from=
 2.6.17 till latest rc
Mine is http://www.nuclearcat.com/config-lo.txt


--=20
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
