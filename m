From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 16:42:07 -0600
Message-ID: <200501121642.10800.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501121621.24259.jeremy.guthrie@berbee.com> <16869.42247.126428.508479@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4355522.dXn12orbkK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16869.42247.126428.508479@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart4355522.dXn12orbkK
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Wed Jan 12 16:36:29 CST 2005
eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          RX packets:1868701 errors:894743 dropped:894743 overruns:410647=20
frame:0
ba659628 150dc67c 00c8ad95 000d2659 00000000 00000000 00000000 00000000=20
00764a9d
00045bd7 00000000 00000120 00000000 00000000 00000000 00000000 00000000=20
0009b5c4
entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_sr=
c =20
out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss=20
gc_dst_overflow in_hlist_search out_hlist_search
00008e84  62d61b7d 37d9063a 00000000 00000000 0000b57e 00006c14 00000002 =20
0027d72c 00042dfa 00000000 307d209e 30505aea 001d0a7c 001cf933 108c7bfb=20
00c976a6
00008e84  0000f0af 00032cd5 00000000 00000000 00004360 00000000 00000000 =20
00000020 000000df 00000002 00004874 000046dd 0000016c 00000165 0016e55d=20
0000028f
           CPU0       CPU1
 18: 3680079907       1815   IO-APIC-level  eth3
 20:          2 2490755322   IO-APIC-level  eth2

Wed Jan 12 16:37:30 CST 2005
eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          RX packets:6313404 errors:1216174 dropped:1216174 overruns:509016=
=20
frame:0
baa97098 150dc67c 00c8e8ac 000d2659 00000000 00000000 00000000 00000000=20
00764df1
00045be8 00000000 00000120 00000000 00000000 00000000 00000000 00000000=20
0009b650
entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_sr=
c =20
out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss=20
gc_dst_overflow in_hlist_search out_hlist_search
0000e10e  63177e31 37db7aec 00000000 00000000 0000b587 00006c22 00000002 =20
0027d819 00042e29 00000000 307f9564 3052cf38 001d0a7f 001cf933 114eef21=20
00c97a1e
0000e10e  0000f0b5 00032ce0 00000000 00000000 00004360 00000000 00000000 =20
00000020 000000e0 00000002 00004875 000046de 0000016c 00000165 0016e5a1=20
00000295
           CPU0       CPU1
 18: 3680513406       1815   IO-APIC-level  eth3
 20:          2 2490979016   IO-APIC-level  eth2


On Wednesday 12 January 2005 04:30 pm, Robert Olsson wrote:
> Can you give this a last try. It's from an older driver
>
>
> e1000_clean(struct net_device *netdev, int *budget)
> {
>         struct e1000_adapter *adapter =3D netdev->priv;
>         int work_to_do =3D min(*budget, netdev->quota);
>         int work_done =3D 0;
>
>         e1000_clean_tx_irq(adapter);
>         e1000_clean_rx_irq(adapter, &work_done, work_to_do);
>
>         *budget -=3D work_done;
>         netdev->quota -=3D work_done;
>
>         if(work_done < work_to_do) {
>                 netif_rx_complete(netdev);
>                 e1000_irq_enable(adapter);
>         }
>
>         return (work_done >=3D work_to_do);
> }

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart4355522.dXn12orbkK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5afCqtjaBHGZBeURAgpOAJ971p9Ju5uTAe+q+b+E2D0T9QDfVgCglf92
r7f9BzwNMV9GwYoKtx1IIWw=
=2kyp
-----END PGP SIGNATURE-----

--nextPart4355522.dXn12orbkK--
