From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 14:30:00 -0600
Message-ID: <200501121430.03763.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501121411.49293.jeremy.guthrie@berbee.com> <16869.34519.31321.977100@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3725316.Z5xNv7sXvu";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16869.34519.31321.977100@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart3725316.Z5xNv7sXvu
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Sorry, here is the latest.  BTW, it is VERY sluggish now.

Wed Jan 12 14:25:03 CST 2005
eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          RX packets:32030222 errors:105026820 dropped:105026820=20
overruns:100748696 frame:0
9651ffeb 150dc67c 00c814c1 000d2659 00000000 00000000 00000000 00000000=20
0073d527
00044681 00000000 000000f8 00000000 00000000 00000000 00000000 00000000=20
00097d42
entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_sr=
c =20
out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss=20
gc_dst_overflow in_hlist_search out_hlist_search
00020000  41c25a6f 34daaca8 00000000 00000000 0000b11d 00006a40 00000002 =20
00272af5 00041525 00000000 2f6a27e5 2f4b712d 000f2bd8 000f1b0e 84036c96=20
00c5e8a8
00020000  0000e336 0003256f 00000000 00000000 00004292 00000000 00000000 =20
0000001e 000000c0 00000002 00004762 0000462a 0000010e 0000010b 0016b898=20
0000024c
           CPU0       CPU1
 18: 3586173518       1815   IO-APIC-level  eth3
 20:          2 2464382507   IO-APIC-level  eth2

Wed Jan 12 14:26:03 CST 2005
eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
          RX packets:32097966 errors:110579564 dropped:110579564=20
overruns:106248073 frame:0
965308aa 150dc67c 00c818e4 000d2659 00000000 00000000 00000000 00000000=20
0073d527
0004468b 00000000 000000f8 00000000 00000000 00000000 00000000 00000000=20
00097d42
entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_sr=
c =20
out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss=20
gc_dst_overflow in_hlist_search out_hlist_search
00020000  41c2602e 34dbaf9f 00000000 00000000 0000b11e 00006a40 00000002 =20
00272af5 00041527 00000000 2f6b2ad8 2f4b9a88 00100571 000ff4a4 84036c9e=20
00c5e8a8
00020000  0000e336 00032578 00000000 00000000 00004292 00000000 00000000 =20
0000001e 000000c0 00000002 00004762 0000462a 0000010e 0000010b 0016b898=20
0000024c
           CPU0       CPU1
 18: 3586173518       1815   IO-APIC-level  eth3
 20:          2 2464387985   IO-APIC-level  eth2




On Wednesday 12 January 2005 02:21 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > Latest numbers after your patch Robert.
>
>  Did the RX interrupts go down?
>
>       --ro
>
>  > Wed Jan 12 14:05:36 CST 2005
>  > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
>  >           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255=
=2E0
>  >           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
>  >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>  >           RX packets:21951496 errors:2412189 dropped:2412189
>  > overruns:377090 frame:0
>  >           TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
>  >           collisions:0 txqueuelen:1000
>  >           RX bytes:3455362966 (3295.2 Mb)  TX bytes:398 (398.0 b)
>  >           Base address:0x22a0 Memory:eff80000-effa0000
>  >
>  > 95b83157 150dc67c 00c734a1 000d2659 00000000 00000000 00000000 00000000
>  > 0073cee4
>  > 00044494 00000000 00000075 00000000 00000000 00000000 00000000 00000000
>  > 00097c77
>  > entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst
>  > in_martian_src out_hit out_slow_tot out_slow_mc  gc_total gc_ignored
>  > gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search
>  > 0000f8cd  41403122 34c30e49 00000000 00000000 0000b0dd 00006a38 000000=
02
>  > 0027279d 0004147b 00000000 2f528a5f 2f42efcf 0000104f 00000000 81d262df
>  > 00c5d75c
>  > 0000f8cd  0000e332 0003238f 00000000 00000000 00004263 00000000 000000=
00
>  > 0000001e 000000c0 00000002 00004650 00004626 00000000 00000000 0016b879
>  > 0000024c
>  >
>  >
>  >
>  >
>  >
>  > Wed Jan 12 14:06:36 CST 2005
>  > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
>  >           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255=
=2E0
>  >           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
>  >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>  >           RX packets:28053281 errors:2899869 dropped:2899869
>  > overruns:427243 frame:0
>  >           TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
>  >           collisions:0 txqueuelen:1000
>  >           RX bytes:2607094069 (2486.3 Mb)  TX bytes:398 (398.0 b)
>  >           Base address:0x22a0 Memory:eff80000-effa0000
>  >
>  > 96154d20 150dc67c 00c78bc2 000d2659 00000000 00000000 00000000 00000000
>  > 0073d31d
>  > 00044499 00000000 00000075 00000000 00000000 00000000 00000000 00000000
>  > 00097d2d
>  > entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst
>  > in_martian_src out_hit out_slow_tot out_slow_mc  gc_total gc_ignored
>  > gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search
>  > 0000fc6a  419ad196 34c586ba 00000000 00000000 0000b0e0 00006a40 000000=
02
>  > 002729c5 000414cb 00000000 2f5502ff 2f4567f7 0000104f 00000000 83790467
>  > 00c5e33c
>  > 0000fc6a  0000e333 00032393 00000000 00000000 00004263 00000000 000000=
00
>  > 0000001e 000000c0 00000002 00004650 00004626 00000000 00000000 0016b898
>  > 0000024c
>  >
>  > On Wednesday 12 January 2005 01:27 pm, Robert Olsson wrote:
>  > > Jeremy M. Guthrie writes:
>  > >  > >  > ETH3 Interrupts(calc'd from below):  1479968
>  > >  > >
>  > >  > >  Very strange...
>  > >  > >
>  > >  > >  eth3 is bound to CPU0 which in turn has all packet load... If =
we
>  > >  > > were to believe your CPU0 was saturated (due to the drops). We
>  > >  > > should see no (RX) interrupts on eth3. But there is a lot... one
>  > >  > > irq per every three packet. Why?
>  > >  >
>  > >  > I have no idea why it would be doing this.
>  > >
>  > >  Huh seems you didn't add the patch I sent. Below is diff from my
>  > > editor to your e1000_main.c
>  > >
>  > >        --ro
>  > >
>  > >
>  > > --- e1000_main.c.jmg 2005-01-12 20:14:08.324168072 +0100
>  > > +++ e1000_main.c 2005-01-12 20:17:24.777302656 +0100
>  > > @@ -2264,14 +2264,13 @@
>  > >   netdev->quota -=3D work_done;
>  > >
>  > >   /* if no Rx and Tx cleanup work was done, exit the polling mode */
>  > > - if(!tx_cleaned || (work_done < work_to_do) ||
>  > > -    !netif_running(netdev)) {
>  > > +  if( (!tx_cleaned && (work_done =3D=3D 0)) || !netif_running(netde=
v)) {
>  > >  quit_polling: netif_rx_complete(netdev);
>  > >    e1000_irq_enable(adapter);
>  > >    return 0;
>  > >   }
>  > >
>  > > - return (work_done >=3D work_to_do);
>  > > + return 1;
>  > >  }
>  > >
>  > >  #endif
>  >
>  > --
>  >
>  > --------------------------------------------------
>  > Jeremy M. Guthrie        jeremy.guthrie@berbee.com
>  > Senior Network Engineer        Phone: 608-298-1061
>  > Berbee                           Fax: 608-288-3007
>  > 5520 Research Park Drive         NOC: 608-298-1102
>  > Madison, WI 53711

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart3725316.Z5xNv7sXvu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5YjLqtjaBHGZBeURAsH+AJ0efVnD+xMKqNPI20V57D1VNckiFwCdGErU
XYeWyG64OPtmrDUj7/SJQkU=
=4akK
-----END PGP SIGNATURE-----

--nextPart3725316.Z5xNv7sXvu--
