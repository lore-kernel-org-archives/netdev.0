From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 14 Jan 2005 08:59:38 -0600
Message-ID: <200501140859.42018.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501131328.34449.jeremy.guthrie@berbee.com> <16870.58414.767012.96364@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart24040128.PuJ0tmka1N";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16870.58414.767012.96364@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart24040128.PuJ0tmka1N
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I ran a script overnight using the modified driver you had given me Robert.=
 =20
it is interesting that there is almost always errors in the interface even=
=20
though we aren't getting dst-cache errors and running ~ 40% free CPU now.  =
I=20
am going to switch over to Jesse's driver to see if his instrumentation hel=
ps=20
nail down where the problem is.

ethtool -S eth3
NIC statistics:
     rx_packets: 2722676103
     tx_packets: 5
     rx_bytes: 1171335471
     tx_bytes: 398
     rx_errors: 8558366
     tx_errors: 0
     rx_dropped: 1951692
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 6606674
     rx_missed_errors: 6606674
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_abort_late_coll: 0
     tx_deferred_ok: 0
     tx_single_coll_ok: 0
     tx_multi_coll_ok: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     rx_align_errors: 0
     tx_tcp_seg_good: 0
     tx_tcp_seg_failed: 0
     rx_flow_control_xon: 0
     rx_flow_control_xoff: 0
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_long_byte_count: 1384150804783
     rx_csum_offload_good: 2542900690
     rx_csum_offload_errors: 243513

01/13/05 19:20:13 entries:  000690f5  Pkts:  948466  Err:  2788  PPS:  6323=
1 =20
Drop %:  0.29%  Eth3RXInt:  411656  Eth2TXInt:  52008
01/13/05 19:20:28 entries:  0006ac8e  Pkts:  967236  Err:  2582  PPS:  6448=
2 =20
Drop %:  0.26%  Eth3RXInt:  412282  Eth2TXInt:  51066
01/13/05 19:20:43 entries:  0006c6f3  Pkts:  974209  Err:  2645  PPS:  6494=
7 =20
Drop %:  0.27%  Eth3RXInt:  412606  Eth2TXInt:  51439
01/13/05 19:20:58 entries:  0006de75  Pkts:  926103  Err:  2654  PPS:  6174=
0 =20
Drop %:  0.28%  Eth3RXInt:  411864  Eth2TXInt:  51888
01/13/05 19:30:03 entries:  00091311  Pkts:  991885  Err:  2507  PPS:  6612=
5 =20
Drop %:  0.25%  Eth3RXInt:  420214  Eth2TXInt:  44873
01/13/05 19:30:18 entries:  00091ecc  Pkts:  935298  Err:  2656  PPS:  6235=
3 =20
Drop %:  0.28%  Eth3RXInt:  411803  Eth2TXInt:  49733
01/13/05 19:30:33 entries:  00092a91  Pkts:  937829  Err:  2797  PPS:  6252=
1 =20
Drop %:  0.29%  Eth3RXInt:  408503  Eth2TXInt:  49473
01/13/05 19:30:48 entries:  00093612  Pkts:  958149  Err:  2698  PPS:  6387=
6 =20
Drop %:  0.28%  Eth3RXInt:  415769  Eth2TXInt:  49552
01/13/05 19:40:08 entries:  000ae2ac  Pkts:  917843  Err:  2654  PPS:  6118=
9 =20
Drop %:  0.28%  Eth3RXInt:  394963  Eth2TXInt:  51912
01/13/05 19:40:23 entries:  000af369  Pkts:  917445  Err:  2117  PPS:  6116=
3 =20
Drop %:  0.23%  Eth3RXInt:  394155  Eth2TXInt:  53112
01/13/05 19:40:38 entries:  000b0272  Pkts:  931697  Err:  2763  PPS:  6211=
3 =20
Drop %:  0.29%  Eth3RXInt:  403602  Eth2TXInt:  51899
01/13/05 19:40:53 entries:  00005de3  Pkts:  854339  Err:  83088  PPS:  569=
55 =20
Drop %:  9.72%  Eth3RXInt:  296451  Eth2TXInt:  62172
01/13/05 19:50:13 entries:  000669e0  Pkts:  910599  Err:  2646  PPS:  6070=
6 =20
Drop %:  0.29%  Eth3RXInt:  402982  Eth2TXInt:  53797
01/13/05 19:50:28 entries:  00068591  Pkts:  921526  Err:  2782  PPS:  6143=
5 =20
Drop %:  0.30%  Eth3RXInt:  408122  Eth2TXInt:  51792
01/13/05 19:50:44 entries:  0006a046  Pkts:  909343  Err:  2996  PPS:  6062=
2 =20
Drop %:  0.32%  Eth3RXInt:  410888  Eth2TXInt:  53315
01/13/05 19:50:59 entries:  0006b968  Pkts:  904949  Err:  2656  PPS:  6032=
9 =20
Drop %:  0.29%  Eth3RXInt:  410376  Eth2TXInt:  53444
01/13/05 20:00:03 entries:  0009188b  Pkts:  907073  Err:  2539  PPS:  6047=
1 =20
Drop %:  0.27%  Eth3RXInt:  408658  Eth2TXInt:  52399
01/13/05 20:00:18 entries:  000924f5  Pkts:  930178  Err:  2386  PPS:  6201=
1 =20
Drop %:  0.25%  Eth3RXInt:  410595  Eth2TXInt:  51822
01/13/05 20:00:33 entries:  000931a3  Pkts:  895381  Err:  2447  PPS:  5969=
2 =20
Drop %:  0.27%  Eth3RXInt:  406246  Eth2TXInt:  52993
01/13/05 20:00:49 entries:  00093c95  Pkts:  908271  Err:  2338  PPS:  6055=
1 =20
Drop %:  0.25%  Eth3RXInt:  416026  Eth2TXInt:  53732
01/13/05 20:10:08 entries:  000ad87d  Pkts:  911705  Err:  2432  PPS:  6078=
0 =20
Drop %:  0.26%  Eth3RXInt:  416020  Eth2TXInt:  51364
01/13/05 20:10:23 entries:  000ae3fc  Pkts:  961446  Err:  2385  PPS:  6409=
6 =20
Drop %:  0.24%  Eth3RXInt:  418902  Eth2TXInt:  48358
01/13/05 20:10:39 entries:  000aee6a  Pkts:  913636  Err:  2347  PPS:  6090=
9 =20
Drop %:  0.25%  Eth3RXInt:  414232  Eth2TXInt:  51236
01/13/05 20:10:54 entries:  00005e36  Pkts:  888657  Err:  88852  PPS:  592=
43 =20
Drop %:  9.99%  Eth3RXInt:  307888  Eth2TXInt:  58891
01/13/05 20:20:14 entries:  00064ea9  Pkts:  837630  Err:  2339  PPS:  5584=
2 =20
Drop %:  0.27%  Eth3RXInt:  398772  Eth2TXInt:  57373
01/13/05 20:20:29 entries:  0006687f  Pkts:  863629  Err:  2205  PPS:  5757=
5 =20
Drop %:  0.25%  Eth3RXInt:  403868  Eth2TXInt:  54794
01/13/05 20:20:44 entries:  00068299  Pkts:  872662  Err:  2487  PPS:  5817=
7 =20
Drop %:  0.28%  Eth3RXInt:  404412  Eth2TXInt:  55279
01/13/05 20:20:59 entries:  0006995c  Pkts:  848795  Err:  2537  PPS:  5658=
6 =20
Drop %:  0.29%  Eth3RXInt:  402853  Eth2TXInt:  56477
01/13/05 20:30:04 entries:  0009b042  Pkts:  875158  Err:  2970  PPS:  5834=
3 =20
Drop %:  0.33%  Eth3RXInt:  382571  Eth2TXInt:  55533
01/13/05 20:30:19 entries:  0009c17f  Pkts:  880014  Err:  2311  PPS:  5866=
7 =20
Drop %:  0.26%  Eth3RXInt:  385079  Eth2TXInt:  53440
01/13/05 20:30:34 entries:  0009d1d6  Pkts:  900716  Err:  2453  PPS:  6004=
7 =20
Drop %:  0.27%  Eth3RXInt:  396762  Eth2TXInt:  54786
01/13/05 20:30:49 entries:  0009e22d  Pkts:  897585  Err:  2453  PPS:  5983=
9 =20
Drop %:  0.27%  Eth3RXInt:  396506  Eth2TXInt:  54240
01/13/05 20:40:08 entries:  000b915f  Pkts:  827962  Err:  2565  PPS:  5519=
7 =20
Drop %:  0.30%  Eth3RXInt:  404875  Eth2TXInt:  58387
01/13/05 20:40:24 entries:  000b9cf2  Pkts:  821150  Err:  2460  PPS:  5474=
3 =20
Drop %:  0.29%  Eth3RXInt:  399397  Eth2TXInt:  58173
01/13/05 20:40:39 entries:  000baaef  Pkts:  878751  Err:  2733  PPS:  5858=
3 =20
Drop %:  0.31%  Eth3RXInt:  402052  Eth2TXInt:  55343
01/13/05 20:40:54 entries:  000062d3  Pkts:  815754  Err:  77364  PPS:  543=
83 =20
Drop %:  9.48%  Eth3RXInt:  298308  Eth2TXInt:  63697
01/13/05 20:50:13 entries:  000655f5  Pkts:  874449  Err:  2589  PPS:  5829=
6 =20
Drop %:  0.29%  Eth3RXInt:  397470  Eth2TXInt:  55040
01/13/05 20:50:29 entries:  000670ef  Pkts:  862434  Err:  2335  PPS:  5749=
5 =20
Drop %:  0.27%  Eth3RXInt:  399384  Eth2TXInt:  55292
01/13/05 20:50:44 entries:  00068e59  Pkts:  904716  Err:  2520  PPS:  6031=
4 =20
Drop %:  0.27%  Eth3RXInt:  401899  Eth2TXInt:  52789
01/13/05 20:50:59 entries:  0006a6af  Pkts:  877349  Err:  2660  PPS:  5848=
9 =20
Drop %:  0.30%  Eth3RXInt:  401982  Eth2TXInt:  54755
01/13/05 21:00:03 entries:  0008ffba  Pkts:  835650  Err:  2127  PPS:  5571=
0 =20
Drop %:  0.25%  Eth3RXInt:  406517  Eth2TXInt:  57597
01/13/05 21:00:18 entries:  00090a7f  Pkts:  842742  Err:  2102  PPS:  5618=
2 =20
Drop %:  0.24%  Eth3RXInt:  407024  Eth2TXInt:  57559
01/13/05 21:00:33 entries:  000915dd  Pkts:  844459  Err:  2683  PPS:  5629=
7 =20
Drop %:  0.31%  Eth3RXInt:  406624  Eth2TXInt:  58553
01/13/05 21:00:48 entries:  000920b6  Pkts:  810715  Err:  2626  PPS:  5404=
7 =20
Drop %:  0.32%  Eth3RXInt:  401342  Eth2TXInt:  59538
01/13/05 21:10:08 entries:  000aa6a7  Pkts:  829066  Err:  2159  PPS:  5527=
1 =20
Drop %:  0.26%  Eth3RXInt:  401210  Eth2TXInt:  56607
01/13/05 21:10:23 entries:  000ab10b  Pkts:  833478  Err:  2350  PPS:  5556=
5 =20
Drop %:  0.28%  Eth3RXInt:  404397  Eth2TXInt:  56495
01/13/05 21:10:38 entries:  000abb70  Pkts:  813251  Err:  2425  PPS:  5421=
6 =20
Drop %:  0.29%  Eth3RXInt:  402135  Eth2TXInt:  57976
01/13/05 21:10:53 entries:  000ac12b  Pkts:  836855  Err:  2315  PPS:  5579=
0 =20
Drop %:  0.27%  Eth3RXInt:  404963  Eth2TXInt:  56857
01/13/05 21:20:13 entries:  000c8587  Pkts:  780311  Err:  2011  PPS:  5202=
0 =20
Drop %:  0.25%  Eth3RXInt:  387437  Eth2TXInt:  60951
01/13/05 21:20:28 entries:  000c927c  Pkts:  781288  Err:  1957  PPS:  5208=
5 =20
Drop %:  0.25%  Eth3RXInt:  386866  Eth2TXInt:  60672
01/13/05 21:20:43 entries:  000c9f80  Pkts:  771294  Err:  2185  PPS:  5141=
9 =20
Drop %:  0.28%  Eth3RXInt:  386213  Eth2TXInt:  61530
01/13/05 21:20:58 entries:  000cabe0  Pkts:  761870  Err:  1847  PPS:  5079=
1 =20
Drop %:  0.24%  Eth3RXInt:  383979  Eth2TXInt:  60613
01/13/05 21:30:02 entries:  000e1471  Pkts:  752945  Err:  2363  PPS:  5019=
6 =20
Drop %:  0.31%  Eth3RXInt:  385445  Eth2TXInt:  62462
01/13/05 21:30:17 entries:  000e20e0  Pkts:  746890  Err:  2179  PPS:  4979=
2 =20
Drop %:  0.29%  Eth3RXInt:  385645  Eth2TXInt:  62886
01/13/05 21:30:32 entries:  000e2bf5  Pkts:  759932  Err:  2353  PPS:  5066=
2 =20
Drop %:  0.30%  Eth3RXInt:  390137  Eth2TXInt:  61938
01/13/05 21:30:47 entries:  000e368c  Pkts:  770359  Err:  2226  PPS:  5135=
7 =20
Drop %:  0.28%  Eth3RXInt:  393035  Eth2TXInt:  62280
01/13/05 21:40:07 entries:  000f66ab  Pkts:  710993  Err:  1425  PPS:  4739=
9 =20
Drop %:  0.20%  Eth3RXInt:  385138  Eth2TXInt:  66570
01/13/05 21:40:22 entries:  000f6eea  Pkts:  722199  Err:  1727  PPS:  4814=
6 =20
Drop %:  0.23%  Eth3RXInt:  386471  Eth2TXInt:  65154
01/13/05 21:40:37 entries:  000f7731  Pkts:  721459  Err:  1858  PPS:  4809=
7 =20
Drop %:  0.25%  Eth3RXInt:  388601  Eth2TXInt:  64437
01/13/05 21:40:52 entries:  00005160  Pkts:  717256  Err:  50031  PPS:  478=
17 =20
Drop %:  6.97%  Eth3RXInt:  301824  Eth2TXInt:  67610
01/13/05 21:50:11 entries:  00060c77  Pkts:  744283  Err:  2209  PPS:  4961=
8 =20
Drop %:  0.29%  Eth3RXInt:  385202  Eth2TXInt:  61977
01/13/05 21:50:26 entries:  0006251c  Pkts:  712155  Err:  1731  PPS:  4747=
7 =20
Drop %:  0.24%  Eth3RXInt:  375784  Eth2TXInt:  63593
01/13/05 21:50:42 entries:  00063f3d  Pkts:  732397  Err:  2502  PPS:  4882=
6 =20
Drop %:  0.34%  Eth3RXInt:  382823  Eth2TXInt:  64629
01/13/05 21:50:57 entries:  00065ea4  Pkts:  732251  Err:  1954  PPS:  4881=
6 =20
Drop %:  0.26%  Eth3RXInt:  372229  Eth2TXInt:  64307
01/13/05 22:00:01 entries:  0008ed30  Pkts:  753502  Err:  1919  PPS:  5023=
3 =20
Drop %:  0.25%  Eth3RXInt:  392290  Eth2TXInt:  63585
01/13/05 22:00:16 entries:  0008f743  Pkts:  765954  Err:  1783  PPS:  5106=
3 =20
Drop %:  0.23%  Eth3RXInt:  398195  Eth2TXInt:  64681
01/13/05 22:00:31 entries:  00090132  Pkts:  745575  Err:  1748  PPS:  4970=
5 =20
Drop %:  0.23%  Eth3RXInt:  393391  Eth2TXInt:  63904
01/13/05 22:00:46 entries:  00090bf1  Pkts:  750483  Err:  1810  PPS:  5003=
2 =20
Drop %:  0.24%  Eth3RXInt:  395678  Eth2TXInt:  65592
01/13/05 22:10:05 entries:  000a69b4  Pkts:  740410  Err:  4101  PPS:  4936=
0 =20
Drop %:  0.55%  Eth3RXInt:  393872  Eth2TXInt:  66508
01/13/05 22:10:20 entries:  000a732d  Pkts:  737503  Err:  3481  PPS:  4916=
6 =20
Drop %:  0.47%  Eth3RXInt:  392793  Eth2TXInt:  67370
01/13/05 22:10:35 entries:  000a7d9a  Pkts:  735129  Err:  3227  PPS:  4900=
8 =20
Drop %:  0.43%  Eth3RXInt:  394918  Eth2TXInt:  67208
01/13/05 22:10:51 entries:  000a87d0  Pkts:  731617  Err:  3099  PPS:  4877=
4 =20
Drop %:  0.42%  Eth3RXInt:  391164  Eth2TXInt:  67757
01/13/05 22:20:09 entries:  000bcb09  Pkts:  674113  Err:  3321  PPS:  4494=
0 =20
Drop %:  0.49%  Eth3RXInt:  379562  Eth2TXInt:  69421
01/13/05 22:20:25 entries:  000bd3b8  Pkts:  666534  Err:  2801  PPS:  4443=
5 =20
Drop %:  0.42%  Eth3RXInt:  377072  Eth2TXInt:  70649
01/13/05 22:20:40 entries:  000bdd19  Pkts:  678034  Err:  2940  PPS:  4520=
2 =20
Drop %:  0.43%  Eth3RXInt:  378198  Eth2TXInt:  69143
01/13/05 22:20:55 entries:  000be345  Pkts:  661543  Err:  2829  PPS:  4410=
2 =20
Drop %:  0.42%  Eth3RXInt:  373469  Eth2TXInt:  69994
01/13/05 22:30:14 entries:  000d1135  Pkts:  678235  Err:  1982  PPS:  4521=
5 =20
Drop %:  0.29%  Eth3RXInt:  373441  Eth2TXInt:  71223
01/13/05 22:30:29 entries:  000d1bf0  Pkts:  685493  Err:  1983  PPS:  4569=
9 =20
Drop %:  0.28%  Eth3RXInt:  373410  Eth2TXInt:  68586
01/13/05 22:30:44 entries:  000d26eb  Pkts:  684653  Err:  2007  PPS:  4564=
3 =20
Drop %:  0.29%  Eth3RXInt:  373354  Eth2TXInt:  68304
01/13/05 22:30:59 entries:  000d2e78  Pkts:  664648  Err:  1527  PPS:  4430=
9 =20
Drop %:  0.22%  Eth3RXInt:  365428  Eth2TXInt:  67413
01/13/05 22:40:03 entries:  000e44b4  Pkts:  645300  Err:  1954  PPS:  4302=
0 =20
Drop %:  0.30%  Eth3RXInt:  369820  Eth2TXInt:  72192
01/13/05 22:40:18 entries:  000e4c66  Pkts:  643369  Err:  1702  PPS:  4289=
1 =20
Drop %:  0.26%  Eth3RXInt:  366982  Eth2TXInt:  72002
01/13/05 22:40:33 entries:  000e5423  Pkts:  634654  Err:  1873  PPS:  4231=
0 =20
Drop %:  0.29%  Eth3RXInt:  367668  Eth2TXInt:  72011
01/13/05 22:40:48 entries:  00002be0  Pkts:  626759  Err:  21655  PPS:  417=
83 =20
Drop %:  3.45%  Eth3RXInt:  317916  Eth2TXInt:  72957
01/13/05 22:50:07 entries:  00057b41  Pkts:  636115  Err:  1548  PPS:  4240=
7 =20
Drop %:  0.24%  Eth3RXInt:  356743  Eth2TXInt:  70117
01/13/05 22:50:22 entries:  00059254  Pkts:  690168  Err:  2081  PPS:  4601=
1 =20
Drop %:  0.30%  Eth3RXInt:  375141  Eth2TXInt:  69588
01/13/05 22:50:37 entries:  0005a923  Pkts:  667265  Err:  1647  PPS:  4448=
4 =20
Drop %:  0.24%  Eth3RXInt:  367504  Eth2TXInt:  69765
01/13/05 22:50:52 entries:  0005be38  Pkts:  646829  Err:  1806  PPS:  4312=
1 =20
Drop %:  0.27%  Eth3RXInt:  361265  Eth2TXInt:  72190
01/13/05 23:00:11 entries:  0008b137  Pkts:  616932  Err:  1566  PPS:  4112=
8 =20
Drop %:  0.25%  Eth3RXInt:  361653  Eth2TXInt:  74776
01/13/05 23:00:26 entries:  0008bd2f  Pkts:  655216  Err:  2433  PPS:  4368=
1 =20
Drop %:  0.37%  Eth3RXInt:  366736  Eth2TXInt:  72637
01/13/05 23:00:42 entries:  0008c6ce  Pkts:  650050  Err:  1792  PPS:  4333=
6 =20
Drop %:  0.27%  Eth3RXInt:  369516  Eth2TXInt:  74231
01/13/05 23:00:57 entries:  0008cf8a  Pkts:  622743  Err:  1628  PPS:  4151=
6 =20
Drop %:  0.26%  Eth3RXInt:  362609  Eth2TXInt:  73576
01/13/05 23:10:00 entries:  0009ec88  Pkts:  558466  Err:  1254  PPS:  3723=
1 =20
Drop %:  0.22%  Eth3RXInt:  341801  Eth2TXInt:  77394
01/13/05 23:10:15 entries:  0009f446  Pkts:  583270  Err:  1727  PPS:  3888=
4 =20
Drop %:  0.29%  Eth3RXInt:  351413  Eth2TXInt:  77099
01/13/05 23:10:31 entries:  0009fd65  Pkts:  585702  Err:  1378  PPS:  3904=
6 =20
Drop %:  0.23%  Eth3RXInt:  352610  Eth2TXInt:  76484
01/13/05 23:10:46 entries:  000a061f  Pkts:  591411  Err:  1389  PPS:  3942=
7 =20
Drop %:  0.23%  Eth3RXInt:  351609  Eth2TXInt:  76353
01/13/05 23:20:04 entries:  000b177a  Pkts:  630155  Err:  1788  PPS:  4201=
0 =20
Drop %:  0.28%  Eth3RXInt:  368741  Eth2TXInt:  76933
01/13/05 23:20:19 entries:  000b2070  Pkts:  608282  Err:  1147  PPS:  4055=
2 =20
Drop %:  0.18%  Eth3RXInt:  356552  Eth2TXInt:  76472
01/13/05 23:20:34 entries:  000b28ae  Pkts:  560094  Err:  1474  PPS:  3733=
9 =20
Drop %:  0.26%  Eth3RXInt:  341610  Eth2TXInt:  77689
01/13/05 23:20:50 entries:  000b314f  Pkts:  559777  Err:  1268  PPS:  3731=
8 =20
Drop %:  0.22%  Eth3RXInt:  342036  Eth2TXInt:  77905
01/13/05 23:30:08 entries:  000c3e43  Pkts:  602182  Err:  1643  PPS:  4014=
5 =20
Drop %:  0.27%  Eth3RXInt:  360109  Eth2TXInt:  76867
01/13/05 23:30:23 entries:  000c456a  Pkts:  544079  Err:  1293  PPS:  3627=
1 =20
Drop %:  0.23%  Eth3RXInt:  337942  Eth2TXInt:  78707
01/13/05 23:30:38 entries:  000c4d58  Pkts:  571859  Err:  1606  PPS:  3812=
3 =20
Drop %:  0.28%  Eth3RXInt:  348591  Eth2TXInt:  78355
01/13/05 23:30:53 entries:  000c4f8d  Pkts:  553967  Err:  1299  PPS:  3693=
1 =20
Drop %:  0.23%  Eth3RXInt:  340507  Eth2TXInt:  77327
01/13/05 23:40:12 entries:  000d5cd4  Pkts:  571850  Err:  1459  PPS:  3812=
3 =20
Drop %:  0.25%  Eth3RXInt:  342271  Eth2TXInt:  77382
01/13/05 23:40:27 entries:  000d66eb  Pkts:  537062  Err:  1233  PPS:  3580=
4 =20
Drop %:  0.22%  Eth3RXInt:  326360  Eth2TXInt:  79641
01/13/05 23:40:42 entries:  000d700d  Pkts:  538091  Err:  1640  PPS:  3587=
2 =20
Drop %:  0.30%  Eth3RXInt:  331841  Eth2TXInt:  79667
01/13/05 23:40:57 entries:  00006e93  Pkts:  534710  Err:  14693  PPS:  356=
47 =20
Drop %:  2.74%  Eth3RXInt:  255177  Eth2TXInt:  78981
01/13/05 23:50:01 entries:  00056e16  Pkts:  574215  Err:  1233  PPS:  3828=
1 =20
Drop %:  0.21%  Eth3RXInt:  337409  Eth2TXInt:  78770
01/13/05 23:50:16 entries:  00058557  Pkts:  537083  Err:  1186  PPS:  3580=
5 =20
Drop %:  0.22%  Eth3RXInt:  324471  Eth2TXInt:  78352
01/13/05 23:50:31 entries:  00059b52  Pkts:  565715  Err:  1586  PPS:  3771=
4 =20
Drop %:  0.28%  Eth3RXInt:  340689  Eth2TXInt:  79699
01/13/05 23:50:46 entries:  0005af99  Pkts:  558546  Err:  1355  PPS:  3723=
6 =20
Drop %:  0.24%  Eth3RXInt:  337133  Eth2TXInt:  78779
01/14/05 00:00:05 entries:  0008504d  Pkts:  588805  Err:  1507  PPS:  3925=
3 =20
Drop %:  0.25%  Eth3RXInt:  346266  Eth2TXInt:  77616
01/14/05 00:00:20 entries:  00085c27  Pkts:  570425  Err:  1672  PPS:  3802=
8 =20
Drop %:  0.29%  Eth3RXInt:  338249  Eth2TXInt:  78085
01/14/05 00:00:35 entries:  00086908  Pkts:  578050  Err:  1327  PPS:  3853=
6 =20
Drop %:  0.22%  Eth3RXInt:  340259  Eth2TXInt:  77927
01/14/05 00:00:50 entries:  00087438  Pkts:  566396  Err:  1135  PPS:  3775=
9 =20
Drop %:  0.20%  Eth3RXInt:  338626  Eth2TXInt:  77983
01/14/05 00:10:09 entries:  0009a1f9  Pkts:  527344  Err:  1364  PPS:  3515=
6 =20
Drop %:  0.25%  Eth3RXInt:  330864  Eth2TXInt:  80726
01/14/05 00:10:24 entries:  0009a950  Pkts:  519107  Err:  1251  PPS:  3460=
7 =20
Drop %:  0.24%  Eth3RXInt:  327638  Eth2TXInt:  81313
01/14/05 00:10:39 entries:  0009b0d4  Pkts:  527377  Err:  1085  PPS:  3515=
8 =20
Drop %:  0.20%  Eth3RXInt:  330084  Eth2TXInt:  80885
01/14/05 00:10:54 entries:  0009b7e8  Pkts:  527706  Err:  1603  PPS:  3518=
0 =20
Drop %:  0.30%  Eth3RXInt:  331284  Eth2TXInt:  80577
01/14/05 00:20:13 entries:  000aa8fa  Pkts:  477646  Err:  1147  PPS:  3184=
3 =20
Drop %:  0.24%  Eth3RXInt:  313514  Eth2TXInt:  81244
01/14/05 00:20:28 entries:  000aaf4c  Pkts:  506930  Err:  1148  PPS:  3379=
5 =20
Drop %:  0.22%  Eth3RXInt:  324715  Eth2TXInt:  80366
01/14/05 00:20:43 entries:  000ab666  Pkts:  538447  Err:  1783  PPS:  3589=
6 =20
Drop %:  0.33%  Eth3RXInt:  340587  Eth2TXInt:  80129
01/14/05 00:20:58 entries:  000abc90  Pkts:  503351  Err:  1151  PPS:  3355=
6 =20
Drop %:  0.22%  Eth3RXInt:  324926  Eth2TXInt:  81205
01/14/05 00:30:01 entries:  000b95f8  Pkts:  503581  Err:  1588  PPS:  3357=
2 =20
Drop %:  0.31%  Eth3RXInt:  323090  Eth2TXInt:  81310
01/14/05 00:30:16 entries:  000b9c10  Pkts:  509557  Err:  1373  PPS:  3397=
0 =20
Drop %:  0.26%  Eth3RXInt:  327946  Eth2TXInt:  80876
01/14/05 00:30:31 entries:  000ba263  Pkts:  498061  Err:  1624  PPS:  3320=
4 =20
Drop %:  0.32%  Eth3RXInt:  320360  Eth2TXInt:  80399
01/14/05 00:30:47 entries:  000ba8af  Pkts:  508690  Err:  1030  PPS:  3391=
2 =20
Drop %:  0.20%  Eth3RXInt:  325848  Eth2TXInt:  80562
01/14/05 00:40:05 entries:  000c8eb0  Pkts:  423203  Err:  925  PPS:  28213=
 =20
Drop %:  0.21%  Eth3RXInt:  289128  Eth2TXInt:  81558
01/14/05 00:40:20 entries:  000c9460  Pkts:  435865  Err:  905  PPS:  29057=
 =20
Drop %:  0.20%  Eth3RXInt:  290040  Eth2TXInt:  81407
01/14/05 00:40:35 entries:  000c9b1d  Pkts:  470792  Err:  987  PPS:  31386=
 =20
Drop %:  0.20%  Eth3RXInt:  306570  Eth2TXInt:  80345
01/14/05 00:40:50 entries:  00003ace  Pkts:  455627  Err:  7859  PPS:  3037=
5 =20
Drop %:  1.72%  Eth3RXInt:  261150  Eth2TXInt:  80456
01/14/05 00:50:09 entries:  0004b083  Pkts:  491755  Err:  1253  PPS:  3278=
3 =20
Drop %:  0.25%  Eth3RXInt:  316362  Eth2TXInt:  81009
01/14/05 00:50:24 entries:  0004c2e2  Pkts:  465117  Err:  975  PPS:  31007=
 =20
Drop %:  0.20%  Eth3RXInt:  301050  Eth2TXInt:  81862
01/14/05 00:50:39 entries:  0004d6dc  Pkts:  459493  Err:  1327  PPS:  3063=
2 =20
Drop %:  0.28%  Eth3RXInt:  298610  Eth2TXInt:  81555
01/14/05 00:50:54 entries:  0004eb2d  Pkts:  487190  Err:  887  PPS:  32479=
 =20
Drop %:  0.18%  Eth3RXInt:  313779  Eth2TXInt:  81653
01/14/05 01:00:12 entries:  0007333a  Pkts:  511807  Err:  1015  PPS:  3412=
0 =20
Drop %:  0.19%  Eth3RXInt:  326166  Eth2TXInt:  80991
01/14/05 01:00:28 entries:  000742bb  Pkts:  490129  Err:  1441  PPS:  3267=
5 =20
Drop %:  0.29%  Eth3RXInt:  315417  Eth2TXInt:  81048
01/14/05 01:00:43 entries:  00075002  Pkts:  480424  Err:  1108  PPS:  3202=
8 =20
Drop %:  0.23%  Eth3RXInt:  312870  Eth2TXInt:  81955
01/14/05 01:00:58 entries:  00075ab5  Pkts:  479570  Err:  1305  PPS:  3197=
1 =20
Drop %:  0.27%  Eth3RXInt:  314682  Eth2TXInt:  81203
01/14/05 01:10:01 entries:  0008979c  Pkts:  450310  Err:  1045  PPS:  3002=
0 =20
Drop %:  0.23%  Eth3RXInt:  290075  Eth2TXInt:  81569
01/14/05 01:10:16 entries:  00089faf  Pkts:  433228  Err:  1053  PPS:  2888=
1 =20
Drop %:  0.24%  Eth3RXInt:  285539  Eth2TXInt:  81461
01/14/05 01:10:31 entries:  0008a763  Pkts:  440048  Err:  1367  PPS:  2933=
6 =20
Drop %:  0.31%  Eth3RXInt:  291495  Eth2TXInt:  81925
01/14/05 01:10:46 entries:  0008af1e  Pkts:  501093  Err:  1510  PPS:  3340=
6 =20
Drop %:  0.30%  Eth3RXInt:  319267  Eth2TXInt:  82134
01/14/05 01:20:05 entries:  0009a978  Pkts:  484885  Err:  1591  PPS:  3232=
5 =20
Drop %:  0.32%  Eth3RXInt:  304961  Eth2TXInt:  80773
01/14/05 01:20:20 entries:  0009b485  Pkts:  497080  Err:  1484  PPS:  3313=
8 =20
Drop %:  0.29%  Eth3RXInt:  310173  Eth2TXInt:  81031
01/14/05 01:20:35 entries:  0009bfd7  Pkts:  503000  Err:  1555  PPS:  3353=
3 =20
Drop %:  0.30%  Eth3RXInt:  315228  Eth2TXInt:  81955
01/14/05 01:20:50 entries:  0009cb17  Pkts:  473078  Err:  1004  PPS:  3153=
8 =20
Drop %:  0.21%  Eth3RXInt:  302143  Eth2TXInt:  82036
01/14/05 01:30:09 entries:  000acb27  Pkts:  485756  Err:  1048  PPS:  3238=
3 =20
Drop %:  0.21%  Eth3RXInt:  315112  Eth2TXInt:  81381
01/14/05 01:30:24 entries:  000ade3e  Pkts:  487954  Err:  1116  PPS:  3253=
0 =20
Drop %:  0.22%  Eth3RXInt:  296615  Eth2TXInt:  80622
01/14/05 01:30:39 entries:  000b1d66  Pkts:  496891  Err:  1365  PPS:  3312=
6 =20
Drop %:  0.27%  Eth3RXInt:  245583  Eth2TXInt:  79328
01/14/05 01:30:54 entries:  000b55c3  Pkts:  525362  Err:  1661  PPS:  3502=
4 =20
Drop %:  0.31%  Eth3RXInt:  249821  Eth2TXInt:  76762
01/14/05 01:40:12 entries:  000c5d9b  Pkts:  441275  Err:  1262  PPS:  2941=
8 =20
Drop %:  0.28%  Eth3RXInt:  295788  Eth2TXInt:  81607
01/14/05 01:40:27 entries:  000c638d  Pkts:  432402  Err:  818  PPS:  28826=
 =20
Drop %:  0.18%  Eth3RXInt:  292080  Eth2TXInt:  82215
01/14/05 01:40:42 entries:  000c6a20  Pkts:  475611  Err:  1137  PPS:  3170=
7 =20
Drop %:  0.23%  Eth3RXInt:  312107  Eth2TXInt:  82512
01/14/05 01:40:58 entries:  000062a2  Pkts:  422599  Err:  3778  PPS:  2817=
3 =20
Drop %:  0.89%  Eth3RXInt:  236232  Eth2TXInt:  81681
01/14/05 01:50:01 entries:  00047c87  Pkts:  434595  Err:  1120  PPS:  2897=
3 =20
Drop %:  0.25%  Eth3RXInt:  291004  Eth2TXInt:  81547
01/14/05 01:50:16 entries:  0004924f  Pkts:  473118  Err:  1018  PPS:  3154=
1 =20
Drop %:  0.21%  Eth3RXInt:  306494  Eth2TXInt:  81818
01/14/05 01:50:31 entries:  0004a615  Pkts:  454845  Err:  807  PPS:  30323=
 =20
Drop %:  0.17%  Eth3RXInt:  300121  Eth2TXInt:  81781
01/14/05 01:50:46 entries:  0004b989  Pkts:  446690  Err:  814  PPS:  29779=
 =20
Drop %:  0.18%  Eth3RXInt:  295153  Eth2TXInt:  82147
01/14/05 02:00:05 entries:  00071828  Pkts:  485939  Err:  1181  PPS:  3239=
5 =20
Drop %:  0.24%  Eth3RXInt:  311765  Eth2TXInt:  81409
01/14/05 02:00:20 entries:  000727ca  Pkts:  473909  Err:  1384  PPS:  3159=
3 =20
Drop %:  0.29%  Eth3RXInt:  307111  Eth2TXInt:  81430
01/14/05 02:00:35 entries:  00073806  Pkts:  477835  Err:  1173  PPS:  3185=
5 =20
Drop %:  0.24%  Eth3RXInt:  308946  Eth2TXInt:  81813
01/14/05 02:00:50 entries:  00074824  Pkts:  481520  Err:  918  PPS:  32101=
 =20
Drop %:  0.19%  Eth3RXInt:  310852  Eth2TXInt:  81876
01/14/05 02:10:08 entries:  0008a6fc  Pkts:  441730  Err:  788  PPS:  29448=
 =20
Drop %:  0.17%  Eth3RXInt:  296119  Eth2TXInt:  82040
01/14/05 02:10:23 entries:  0008ae30  Pkts:  462573  Err:  964  PPS:  30838=
 =20
Drop %:  0.20%  Eth3RXInt:  305317  Eth2TXInt:  82031
01/14/05 02:10:39 entries:  0008b5ce  Pkts:  462473  Err:  1037  PPS:  3083=
1 =20
Drop %:  0.22%  Eth3RXInt:  305753  Eth2TXInt:  81449
01/14/05 02:10:54 entries:  0008baee  Pkts:  433606  Err:  885  PPS:  28907=
 =20
Drop %:  0.20%  Eth3RXInt:  291876  Eth2TXInt:  81471
01/14/05 02:20:12 entries:  0009a92d  Pkts:  458960  Err:  851  PPS:  30597=
 =20
Drop %:  0.18%  Eth3RXInt:  303308  Eth2TXInt:  81503
01/14/05 02:20:27 entries:  0009b002  Pkts:  498472  Err:  1221  PPS:  3323=
1 =20
Drop %:  0.24%  Eth3RXInt:  325077  Eth2TXInt:  81679
01/14/05 02:20:42 entries:  0009b68c  Pkts:  484378  Err:  1176  PPS:  3229=
1 =20
Drop %:  0.24%  Eth3RXInt:  317011  Eth2TXInt:  80552
01/14/05 02:20:57 entries:  0009b9cf  Pkts:  448711  Err:  932  PPS:  29914=
 =20
Drop %:  0.20%  Eth3RXInt:  300504  Eth2TXInt:  81309
01/14/05 02:30:01 entries:  000abe83  Pkts:  485720  Err:  1211  PPS:  3238=
1 =20
Drop %:  0.24%  Eth3RXInt:  317102  Eth2TXInt:  81805
01/14/05 02:30:16 entries:  000ac418  Pkts:  456824  Err:  770  PPS:  30454=
 =20
Drop %:  0.16%  Eth3RXInt:  303707  Eth2TXInt:  82063
01/14/05 02:30:31 entries:  000aca2e  Pkts:  464268  Err:  926  PPS:  30951=
 =20
Drop %:  0.19%  Eth3RXInt:  307084  Eth2TXInt:  82922
01/14/05 02:30:46 entries:  000acfd9  Pkts:  488002  Err:  1199  PPS:  3253=
3 =20
Drop %:  0.24%  Eth3RXInt:  317994  Eth2TXInt:  82220
01/14/05 02:40:04 entries:  000b939f  Pkts:  426137  Err:  1071  PPS:  2840=
9 =20
Drop %:  0.25%  Eth3RXInt:  291613  Eth2TXInt:  80942
01/14/05 02:40:19 entries:  000b99b8  Pkts:  435682  Err:  641  PPS:  29045=
 =20
Drop %:  0.14%  Eth3RXInt:  295451  Eth2TXInt:  81203
01/14/05 02:40:34 entries:  000ba164  Pkts:  469842  Err:  1099  PPS:  3132=
2 =20
Drop %:  0.23%  Eth3RXInt:  310350  Eth2TXInt:  81309
01/14/05 02:40:50 entries:  000039d8  Pkts:  432433  Err:  4158  PPS:  2882=
8 =20
Drop %:  0.96%  Eth3RXInt:  258916  Eth2TXInt:  79816
01/14/05 02:50:08 entries:  00045e02  Pkts:  411631  Err:  1073  PPS:  2744=
2 =20
Drop %:  0.26%  Eth3RXInt:  278161  Eth2TXInt:  81417
01/14/05 02:50:23 entries:  00046f7b  Pkts:  410141  Err:  795  PPS:  27342=
 =20
Drop %:  0.19%  Eth3RXInt:  275966  Eth2TXInt:  81285
01/14/05 02:50:38 entries:  000481d2  Pkts:  433426  Err:  1245  PPS:  2889=
5 =20
Drop %:  0.28%  Eth3RXInt:  289269  Eth2TXInt:  81567
01/14/05 02:50:53 entries:  000493db  Pkts:  412782  Err:  969  PPS:  27518=
 =20
Drop %:  0.23%  Eth3RXInt:  277938  Eth2TXInt:  81170
01/14/05 03:00:12 entries:  00075b30  Pkts:  525329  Err:  1144  PPS:  3502=
1 =20
Drop %:  0.21%  Eth3RXInt:  335221  Eth2TXInt:  82922
01/14/05 03:00:27 entries:  00076ad2  Pkts:  517248  Err:  1513  PPS:  3448=
3 =20
Drop %:  0.29%  Eth3RXInt:  325825  Eth2TXInt:  82644
01/14/05 03:00:42 entries:  000778c5  Pkts:  455097  Err:  1211  PPS:  3033=
9 =20
Drop %:  0.26%  Eth3RXInt:  301609  Eth2TXInt:  81940
01/14/05 03:00:57 entries:  000785d8  Pkts:  472256  Err:  1428  PPS:  3148=
3 =20
Drop %:  0.30%  Eth3RXInt:  308709  Eth2TXInt:  82655
01/14/05 03:10:00 entries:  0008c8fd  Pkts:  474980  Err:  1191  PPS:  3166=
5 =20
Drop %:  0.25%  Eth3RXInt:  305622  Eth2TXInt:  80539
01/14/05 03:10:15 entries:  0008d062  Pkts:  457870  Err:  1130  PPS:  3052=
4 =20
Drop %:  0.24%  Eth3RXInt:  296680  Eth2TXInt:  82396
01/14/05 03:10:30 entries:  0008d73b  Pkts:  480551  Err:  1381  PPS:  3203=
6 =20
Drop %:  0.28%  Eth3RXInt:  309356  Eth2TXInt:  81644
01/14/05 03:10:46 entries:  0008ddd3  Pkts:  465617  Err:  950  PPS:  31041=
 =20
Drop %:  0.20%  Eth3RXInt:  304579  Eth2TXInt:  82222
01/14/05 03:20:04 entries:  0009e568  Pkts:  457937  Err:  1151  PPS:  3052=
9 =20
Drop %:  0.25%  Eth3RXInt:  305244  Eth2TXInt:  81326
01/14/05 03:20:19 entries:  0009eb65  Pkts:  436354  Err:  938  PPS:  29090=
 =20
Drop %:  0.21%  Eth3RXInt:  292012  Eth2TXInt:  81560
01/14/05 03:20:34 entries:  0009f1d4  Pkts:  420677  Err:  863  PPS:  28045=
 =20
Drop %:  0.20%  Eth3RXInt:  285478  Eth2TXInt:  81628
01/14/05 03:20:49 entries:  0009f71d  Pkts:  451901  Err:  838  PPS:  30126=
 =20
Drop %:  0.18%  Eth3RXInt:  302797  Eth2TXInt:  81472
01/14/05 03:30:08 entries:  000ab0e6  Pkts:  496468  Err:  935  PPS:  33097=
 =20
Drop %:  0.18%  Eth3RXInt:  313564  Eth2TXInt:  81825
01/14/05 03:30:23 entries:  000ab6d9  Pkts:  487412  Err:  1234  PPS:  3249=
4 =20
Drop %:  0.25%  Eth3RXInt:  311207  Eth2TXInt:  81957
01/14/05 03:30:38 entries:  000abd71  Pkts:  486905  Err:  1197  PPS:  3246=
0 =20
Drop %:  0.24%  Eth3RXInt:  309132  Eth2TXInt:  81431
01/14/05 03:30:53 entries:  000ac18a  Pkts:  501542  Err:  1095  PPS:  3343=
6 =20
Drop %:  0.21%  Eth3RXInt:  317566  Eth2TXInt:  82225
01/14/05 03:40:11 entries:  000b7c09  Pkts:  453065  Err:  1297  PPS:  3020=
4 =20
Drop %:  0.28%  Eth3RXInt:  301844  Eth2TXInt:  81878
01/14/05 03:40:26 entries:  000b80c8  Pkts:  419895  Err:  794  PPS:  27993=
 =20
Drop %:  0.18%  Eth3RXInt:  286286  Eth2TXInt:  81854
01/14/05 03:40:41 entries:  000b85bf  Pkts:  437850  Err:  871  PPS:  29190=
 =20
Drop %:  0.19%  Eth3RXInt:  296486  Eth2TXInt:  81568
01/14/05 03:40:56 entries:  00005a7b  Pkts:  441752  Err:  4133  PPS:  2945=
0 =20
Drop %:  0.93%  Eth3RXInt:  246594  Eth2TXInt:  80314
01/14/05 03:50:00 entries:  00046892  Pkts:  403034  Err:  1065  PPS:  2686=
8 =20
Drop %:  0.26%  Eth3RXInt:  274784  Eth2TXInt:  81157
01/14/05 03:50:15 entries:  000476c7  Pkts:  435578  Err:  729  PPS:  29038=
 =20
Drop %:  0.16%  Eth3RXInt:  292309  Eth2TXInt:  81034
01/14/05 03:50:30 entries:  000486aa  Pkts:  412410  Err:  828  PPS:  27494=
 =20
Drop %:  0.20%  Eth3RXInt:  278210  Eth2TXInt:  81402
01/14/05 03:50:45 entries:  000495b6  Pkts:  416286  Err:  1004  PPS:  2775=
2 =20
Drop %:  0.24%  Eth3RXInt:  281510  Eth2TXInt:  81008
01/14/05 04:00:03 entries:  0006a815  Pkts:  475366  Err:  1129  PPS:  3169=
1 =20
Drop %:  0.23%  Eth3RXInt:  307887  Eth2TXInt:  81480
01/14/05 04:00:18 entries:  0006b54b  Pkts:  474234  Err:  1045  PPS:  3161=
5 =20
Drop %:  0.22%  Eth3RXInt:  307872  Eth2TXInt:  81418
01/14/05 04:00:34 entries:  0006c1b3  Pkts:  468519  Err:  920  PPS:  31234=
 =20
Drop %:  0.19%  Eth3RXInt:  309532  Eth2TXInt:  81400
01/14/05 04:00:49 entries:  0006cec6  Pkts:  427386  Err:  701  PPS:  28492=
 =20
Drop %:  0.16%  Eth3RXInt:  288788  Eth2TXInt:  80951
01/14/05 04:10:07 entries:  0008b49a  Pkts:  450361  Err:  0  PPS:  30024 =
=20
Drop %:  0.0%  Eth3RXInt:  298760  Eth2TXInt:  82346
01/14/05 04:10:22 entries:  0008ba59  Pkts:  459431  Err:  0  PPS:  30628 =
=20
Drop %:  0.0%  Eth3RXInt:  301596  Eth2TXInt:  81793
01/14/05 04:10:37 entries:  0008c017  Pkts:  450040  Err:  0  PPS:  30002 =
=20
Drop %:  0.0%  Eth3RXInt:  298585  Eth2TXInt:  81996
01/14/05 04:10:52 entries:  0008c2e9  Pkts:  454740  Err:  963  PPS:  30316=
 =20
Drop %:  0.21%  Eth3RXInt:  299204  Eth2TXInt:  82428
01/14/05 04:20:11 entries:  0009746e  Pkts:  417841  Err:  1077  PPS:  2785=
6 =20
Drop %:  0.25%  Eth3RXInt:  285292  Eth2TXInt:  81971
01/14/05 04:20:26 entries:  00097988  Pkts:  444129  Err:  834  PPS:  29608=
 =20
Drop %:  0.18%  Eth3RXInt:  294925  Eth2TXInt:  82172
01/14/05 04:20:41 entries:  00097e6c  Pkts:  440004  Err:  1152  PPS:  2933=
3 =20
Drop %:  0.26%  Eth3RXInt:  298454  Eth2TXInt:  82420
01/14/05 04:20:56 entries:  000982c8  Pkts:  483248  Err:  1265  PPS:  3221=
6 =20
Drop %:  0.26%  Eth3RXInt:  312325  Eth2TXInt:  80981
01/14/05 04:30:15 entries:  000a66f5  Pkts:  455322  Err:  1273  PPS:  3035=
4 =20
Drop %:  0.27%  Eth3RXInt:  302449  Eth2TXInt:  82011
01/14/05 04:30:30 entries:  000a6c4f  Pkts:  443848  Err:  938  PPS:  29589=
 =20
Drop %:  0.21%  Eth3RXInt:  296296  Eth2TXInt:  82826
01/14/05 04:30:45 entries:  000a714d  Pkts:  457830  Err:  906  PPS:  30522=
 =20
Drop %:  0.19%  Eth3RXInt:  303239  Eth2TXInt:  82669
01/14/05 04:40:03 entries:  000b3c19  Pkts:  443891  Err:  1363  PPS:  2959=
2 =20
Drop %:  0.30%  Eth3RXInt:  298216  Eth2TXInt:  81958
01/14/05 04:40:18 entries:  000b4131  Pkts:  436785  Err:  1055  PPS:  2911=
9 =20
Drop %:  0.24%  Eth3RXInt:  293404  Eth2TXInt:  81866
01/14/05 04:40:33 entries:  000b4670  Pkts:  418272  Err:  886  PPS:  27884=
 =20
Drop %:  0.21%  Eth3RXInt:  284868  Eth2TXInt:  82277
01/14/05 04:40:48 entries:  00003a13  Pkts:  433659  Err:  5106  PPS:  2891=
0 =20
Drop %:  1.17%  Eth3RXInt:  254964  Eth2TXInt:  80964
01/14/05 04:50:07 entries:  000487b1  Pkts:  426580  Err:  825  PPS:  28438=
 =20
Drop %:  0.19%  Eth3RXInt:  284115  Eth2TXInt:  81550
01/14/05 04:50:22 entries:  000499d9  Pkts:  429040  Err:  782  PPS:  28602=
 =20
Drop %:  0.18%  Eth3RXInt:  286171  Eth2TXInt:  81600
01/14/05 04:50:37 entries:  0004ab30  Pkts:  425725  Err:  965  PPS:  28381=
 =20
Drop %:  0.22%  Eth3RXInt:  287211  Eth2TXInt:  81419
01/14/05 04:50:52 entries:  0004bc1b  Pkts:  453751  Err:  1116  PPS:  3025=
0 =20
Drop %:  0.24%  Eth3RXInt:  296099  Eth2TXInt:  81084
01/14/05 05:00:11 entries:  000744da  Pkts:  515817  Err:  1322  PPS:  3438=
7 =20
Drop %:  0.25%  Eth3RXInt:  319462  Eth2TXInt:  81837
01/14/05 05:00:26 entries:  00075866  Pkts:  524724  Err:  1613  PPS:  3498=
1 =20
Drop %:  0.30%  Eth3RXInt:  320024  Eth2TXInt:  81871
01/14/05 05:00:41 entries:  000768aa  Pkts:  513511  Err:  1273  PPS:  3423=
4 =20
Drop %:  0.24%  Eth3RXInt:  319514  Eth2TXInt:  81763
01/14/05 05:00:56 entries:  00077652  Pkts:  521796  Err:  1088  PPS:  3478=
6 =20
Drop %:  0.20%  Eth3RXInt:  322121  Eth2TXInt:  81846
01/14/05 05:10:14 entries:  0008bcd7  Pkts:  441778  Err:  1271  PPS:  2945=
1 =20
Drop %:  0.28%  Eth3RXInt:  293564  Eth2TXInt:  81867
01/14/05 05:10:29 entries:  0008c48f  Pkts:  457062  Err:  1177  PPS:  3047=
0 =20
Drop %:  0.25%  Eth3RXInt:  301042  Eth2TXInt:  82350
01/14/05 05:10:45 entries:  0008cb53  Pkts:  459844  Err:  940  PPS:  30656=
 =20
Drop %:  0.20%  Eth3RXInt:  303190  Eth2TXInt:  82519
01/14/05 05:20:03 entries:  0009b445  Pkts:  478691  Err:  889  PPS:  31912=
 =20
Drop %:  0.18%  Eth3RXInt:  313378  Eth2TXInt:  82914
01/14/05 05:20:18 entries:  0009ba72  Pkts:  485207  Err:  960  PPS:  32347=
 =20
Drop %:  0.19%  Eth3RXInt:  316409  Eth2TXInt:  82264
01/14/05 05:20:33 entries:  0009c150  Pkts:  486224  Err:  879  PPS:  32414=
 =20
Drop %:  0.18%  Eth3RXInt:  314240  Eth2TXInt:  81731
01/14/05 05:20:48 entries:  0009c35b  Pkts:  449497  Err:  1155  PPS:  2996=
6 =20
Drop %:  0.25%  Eth3RXInt:  299010  Eth2TXInt:  82788
01/14/05 05:30:07 entries:  000ab4ea  Pkts:  485299  Err:  1095  PPS:  3235=
3 =20
Drop %:  0.22%  Eth3RXInt:  314318  Eth2TXInt:  82271
01/14/05 05:30:22 entries:  000abae8  Pkts:  490269  Err:  797  PPS:  32684=
 =20
Drop %:  0.16%  Eth3RXInt:  317205  Eth2TXInt:  82521
01/14/05 05:30:37 entries:  000ac134  Pkts:  496198  Err:  1132  PPS:  3307=
9 =20
Drop %:  0.22%  Eth3RXInt:  318933  Eth2TXInt:  81960
01/14/05 05:30:52 entries:  000ac2a1  Pkts:  501254  Err:  954  PPS:  33416=
 =20
Drop %:  0.19%  Eth3RXInt:  324082  Eth2TXInt:  83014
01/14/05 05:40:11 entries:  000baeeb  Pkts:  593611  Err:  1357  PPS:  3957=
4 =20
Drop %:  0.22%  Eth3RXInt:  360758  Eth2TXInt:  81969
01/14/05 05:40:26 entries:  000bb507  Pkts:  567372  Err:  1385  PPS:  3782=
4 =20
Drop %:  0.24%  Eth3RXInt:  350017  Eth2TXInt:  82295
01/14/05 05:40:41 entries:  000bbb4c  Pkts:  495626  Err:  1517  PPS:  3304=
1 =20
Drop %:  0.30%  Eth3RXInt:  320385  Eth2TXInt:  81689
01/14/05 05:40:56 entries:  00006b5a  Pkts:  488706  Err:  6440  PPS:  3258=
0 =20
Drop %:  1.31%  Eth3RXInt:  247798  Eth2TXInt:  80410
01/14/05 05:50:14 entries:  0004e410  Pkts:  500546  Err:  1278  PPS:  3336=
9 =20
Drop %:  0.25%  Eth3RXInt:  310059  Eth2TXInt:  80386
01/14/05 05:50:29 entries:  0004f8e5  Pkts:  506876  Err:  1275  PPS:  3379=
1 =20
Drop %:  0.25%  Eth3RXInt:  316871  Eth2TXInt:  81128
01/14/05 05:50:45 entries:  00050dc1  Pkts:  510450  Err:  1152  PPS:  3403=
0 =20
Drop %:  0.22%  Eth3RXInt:  320390  Eth2TXInt:  80666
01/14/05 06:00:03 entries:  0008089f  Pkts:  519631  Err:  1531  PPS:  3464=
2 =20
Drop %:  0.29%  Eth3RXInt:  323648  Eth2TXInt:  79945
01/14/05 06:00:18 entries:  00081247  Pkts:  535934  Err:  1163  PPS:  3572=
8 =20
Drop %:  0.21%  Eth3RXInt:  327138  Eth2TXInt:  79790
01/14/05 06:00:33 entries:  00081bb3  Pkts:  540473  Err:  1305  PPS:  3603=
1 =20
Drop %:  0.24%  Eth3RXInt:  332823  Eth2TXInt:  79750
01/14/05 06:00:48 entries:  00082320  Pkts:  541275  Err:  1622  PPS:  3608=
5 =20
Drop %:  0.29%  Eth3RXInt:  334946  Eth2TXInt:  79207
01/14/05 06:10:07 entries:  00095795  Pkts:  559209  Err:  1351  PPS:  3728=
0 =20
Drop %:  0.24%  Eth3RXInt:  336161  Eth2TXInt:  79479
01/14/05 06:10:22 entries:  000963c0  Pkts:  540560  Err:  1095  PPS:  3603=
7 =20
Drop %:  0.20%  Eth3RXInt:  323433  Eth2TXInt:  79487
01/14/05 06:10:37 entries:  00096fa6  Pkts:  559203  Err:  1492  PPS:  3728=
0 =20
Drop %:  0.26%  Eth3RXInt:  330691  Eth2TXInt:  80035
01/14/05 06:10:52 entries:  000979fb  Pkts:  542626  Err:  1438  PPS:  3617=
5 =20
Drop %:  0.26%  Eth3RXInt:  325674  Eth2TXInt:  79483
01/14/05 06:20:11 entries:  000ad185  Pkts:  537524  Err:  1585  PPS:  3583=
4 =20
Drop %:  0.29%  Eth3RXInt:  329987  Eth2TXInt:  79144
01/14/05 06:20:26 entries:  000adaba  Pkts:  513026  Err:  1035  PPS:  3420=
1 =20
Drop %:  0.20%  Eth3RXInt:  317912  Eth2TXInt:  79128
01/14/05 06:20:41 entries:  000ae400  Pkts:  532172  Err:  1700  PPS:  3547=
8 =20
Drop %:  0.31%  Eth3RXInt:  326356  Eth2TXInt:  79715
01/14/05 06:20:56 entries:  000aeb41  Pkts:  580261  Err:  1658  PPS:  3868=
4 =20
Drop %:  0.28%  Eth3RXInt:  346806  Eth2TXInt:  79013
01/14/05 06:30:00 entries:  000c1594  Pkts:  572401  Err:  1903  PPS:  3816=
0 =20
Drop %:  0.33%  Eth3RXInt:  341422  Eth2TXInt:  78273
01/14/05 06:30:15 entries:  000c1ea7  Pkts:  585850  Err:  1822  PPS:  3905=
6 =20
Drop %:  0.31%  Eth3RXInt:  345728  Eth2TXInt:  77805
01/14/05 06:30:30 entries:  000c27b2  Pkts:  594077  Err:  1693  PPS:  3960=
5 =20
Drop %:  0.28%  Eth3RXInt:  348358  Eth2TXInt:  76571
01/14/05 06:30:45 entries:  000c3123  Pkts:  582267  Err:  1706  PPS:  3881=
7 =20
Drop %:  0.29%  Eth3RXInt:  342533  Eth2TXInt:  77763
01/14/05 06:40:04 entries:  000dfb48  Pkts:  710678  Err:  2075  PPS:  4737=
8 =20
Drop %:  0.29%  Eth3RXInt:  377850  Eth2TXInt:  70656
01/14/05 06:40:19 entries:  000e083c  Pkts:  660634  Err:  1777  PPS:  4404=
2 =20
Drop %:  0.26%  Eth3RXInt:  353285  Eth2TXInt:  71353
01/14/05 06:40:34 entries:  000e131e  Pkts:  683136  Err:  1696  PPS:  4554=
2 =20
Drop %:  0.24%  Eth3RXInt:  369381  Eth2TXInt:  72622
01/14/05 06:40:49 entries:  00005c1d  Pkts:  713262  Err:  36148  PPS:  475=
50 =20
Drop %:  50.6%  Eth3RXInt:  286910  Eth2TXInt:  71729
01/14/05 06:50:08 entries:  0006066c  Pkts:  695785  Err:  1970  PPS:  4638=
5 =20
Drop %:  0.28%  Eth3RXInt:  368369  Eth2TXInt:  73034
01/14/05 06:50:23 entries:  0006209f  Pkts:  705028  Err:  1715  PPS:  4700=
1 =20
Drop %:  0.24%  Eth3RXInt:  368574  Eth2TXInt:  72892
01/14/05 06:50:38 entries:  000639ca  Pkts:  702841  Err:  1706  PPS:  4685=
6 =20
Drop %:  0.24%  Eth3RXInt:  370024  Eth2TXInt:  72876
01/14/05 06:50:54 entries:  000651d2  Pkts:  726747  Err:  2020  PPS:  4844=
9 =20
Drop %:  0.27%  Eth3RXInt:  376832  Eth2TXInt:  71366
01/14/05 07:00:13 entries:  0008f249  Pkts:  677362  Err:  1595  PPS:  4515=
7 =20
Drop %:  0.23%  Eth3RXInt:  370724  Eth2TXInt:  69981
01/14/05 07:00:28 entries:  0008fe96  Pkts:  662406  Err:  1423  PPS:  4416=
0 =20
Drop %:  0.21%  Eth3RXInt:  362967  Eth2TXInt:  72611
01/14/05 07:00:43 entries:  00090c13  Pkts:  662222  Err:  1844  PPS:  4414=
8 =20
Drop %:  0.27%  Eth3RXInt:  359869  Eth2TXInt:  72181
01/14/05 07:00:58 entries:  00091789  Pkts:  656859  Err:  1729  PPS:  4379=
0 =20
Drop %:  0.26%  Eth3RXInt:  358838  Eth2TXInt:  70074
01/14/05 07:10:02 entries:  000abdb6  Pkts:  697539  Err:  2042  PPS:  4650=
2 =20
Drop %:  0.29%  Eth3RXInt:  379747  Eth2TXInt:  70269
01/14/05 07:10:17 entries:  000ac9d9  Pkts:  704847  Err:  1847  PPS:  4698=
9 =20
Drop %:  0.26%  Eth3RXInt:  374670  Eth2TXInt:  69898
01/14/05 07:10:32 entries:  000ad57b  Pkts:  703755  Err:  2090  PPS:  4691=
7 =20
Drop %:  0.29%  Eth3RXInt:  377955  Eth2TXInt:  70850
01/14/05 07:10:47 entries:  000adebf  Pkts:  709598  Err:  1790  PPS:  4730=
6 =20
Drop %:  0.25%  Eth3RXInt:  379562  Eth2TXInt:  69334
01/14/05 07:20:06 entries:  000c9ceb  Pkts:  790839  Err:  2372  PPS:  5272=
2 =20
Drop %:  0.29%  Eth3RXInt:  392123  Eth2TXInt:  63101
01/14/05 07:20:21 entries:  000caa53  Pkts:  815293  Err:  2200  PPS:  5435=
2 =20
Drop %:  0.26%  Eth3RXInt:  391243  Eth2TXInt:  63859
01/14/05 07:20:37 entries:  000cb70a  Pkts:  801060  Err:  2421  PPS:  5340=
4 =20
Drop %:  0.30%  Eth3RXInt:  392279  Eth2TXInt:  63283
01/14/05 07:20:52 entries:  000cc107  Pkts:  816395  Err:  2279  PPS:  5442=
6 =20
Drop %:  0.27%  Eth3RXInt:  390125  Eth2TXInt:  63646
01/14/05 07:30:11 entries:  000e682c  Pkts:  817455  Err:  2501  PPS:  5449=
7 =20
Drop %:  0.30%  Eth3RXInt:  396197  Eth2TXInt:  63137
01/14/05 07:30:26 entries:  000e756b  Pkts:  820908  Err:  2438  PPS:  5472=
7 =20
Drop %:  0.29%  Eth3RXInt:  391849  Eth2TXInt:  63660
01/14/05 07:30:41 entries:  000e8389  Pkts:  816010  Err:  2613  PPS:  5440=
0 =20
Drop %:  0.32%  Eth3RXInt:  392971  Eth2TXInt:  64416
01/14/05 07:30:56 entries:  000e8d18  Pkts:  827390  Err:  2536  PPS:  5515=
9 =20
Drop %:  0.30%  Eth3RXInt:  394834  Eth2TXInt:  61765
01/14/05 07:40:01 entries:  0010436e  Pkts:  863423  Err:  2368  PPS:  5756=
1 =20
Drop %:  0.27%  Eth3RXInt:  405190  Eth2TXInt:  60998
01/14/05 07:40:16 entries:  00104fda  Pkts:  858511  Err:  2494  PPS:  5723=
4 =20
Drop %:  0.29%  Eth3RXInt:  403185  Eth2TXInt:  61815
01/14/05 07:40:31 entries:  00105c15  Pkts:  854565  Err:  2470  PPS:  5697=
1 =20
Drop %:  0.28%  Eth3RXInt:  404894  Eth2TXInt:  61287
01/14/05 07:40:46 entries:  000057a0  Pkts:  826768  Err:  113636  PPS:  55=
117 =20
Drop %:  13.74%  Eth3RXInt:  302767  Eth2TXInt:  65567
01/14/05 07:50:06 entries:  00079684  Pkts:  913524  Err:  2245  PPS:  6090=
1 =20
Drop %:  0.24%  Eth3RXInt:  400066  Eth2TXInt:  58282
01/14/05 07:50:21 entries:  0007b783  Pkts:  864505  Err:  2505  PPS:  5763=
3 =20
Drop %:  0.28%  Eth3RXInt:  393922  Eth2TXInt:  61211
01/14/05 07:50:36 entries:  0007d8a8  Pkts:  883376  Err:  2693  PPS:  5889=
1 =20
Drop %:  0.30%  Eth3RXInt:  397785  Eth2TXInt:  61160
01/14/05 07:50:51 entries:  0007f40c  Pkts:  858829  Err:  2394  PPS:  5725=
5 =20
Drop %:  0.27%  Eth3RXInt:  398098  Eth2TXInt:  60954
01/14/05 08:00:11 entries:  000a460b  Pkts:  1000645  Err:  2906  PPS:  667=
09 =20
Drop %:  0.29%  Eth3RXInt:  406845  Eth2TXInt:  53497
01/14/05 08:00:26 entries:  000a55a7  Pkts:  965824  Err:  3062  PPS:  6438=
8 =20
Drop %:  0.31%  Eth3RXInt:  402766  Eth2TXInt:  54223
01/14/05 08:00:41 entries:  000a6548  Pkts:  975763  Err:  3184  PPS:  6505=
0 =20
Drop %:  0.32%  Eth3RXInt:  408337  Eth2TXInt:  55173
01/14/05 08:00:56 entries:  000a726e  Pkts:  963100  Err:  3105  PPS:  6420=
6 =20
Drop %:  0.32%  Eth3RXInt:  409883  Eth2TXInt:  54808
01/14/05 08:10:01 entries:  000c7fc9  Pkts:  1045671  Err:  2629  PPS:  697=
11 =20
Drop %:  0.25%  Eth3RXInt:  412912  Eth2TXInt:  52786
01/14/05 08:10:16 entries:  000c8dd3  Pkts:  1059809  Err:  3206  PPS:  706=
53 =20
Drop %:  0.30%  Eth3RXInt:  414254  Eth2TXInt:  51833
01/14/05 08:10:32 entries:  000c9c1a  Pkts:  1026487  Err:  3277  PPS:  684=
32 =20
Drop %:  0.31%  Eth3RXInt:  414313  Eth2TXInt:  51822
01/14/05 08:10:47 entries:  000ca57f  Pkts:  1026565  Err:  3149  PPS:  684=
37 =20
Drop %:  0.30%  Eth3RXInt:  412748  Eth2TXInt:  51581
01/14/05 08:20:07 entries:  000eb744  Pkts:  1086031  Err:  3287  PPS:  724=
02 =20
Drop %:  0.30%  Eth3RXInt:  406328  Eth2TXInt:  48924
01/14/05 08:20:22 entries:  000ec65d  Pkts:  1066622  Err:  2733  PPS:  711=
08 =20
Drop %:  0.25%  Eth3RXInt:  408729  Eth2TXInt:  49285
01/14/05 08:20:37 entries:  000ed550  Pkts:  1069185  Err:  2919  PPS:  712=
79 =20
Drop %:  0.27%  Eth3RXInt:  409380  Eth2TXInt:  49829
01/14/05 08:20:52 entries:  000ede68  Pkts:  1098310  Err:  3181  PPS:  732=
20 =20
Drop %:  0.28%  Eth3RXInt:  414812  Eth2TXInt:  50289
01/14/05 08:30:12 entries:  0010ba04  Pkts:  1132309  Err:  3248  PPS:  754=
87 =20
Drop %:  0.28%  Eth3RXInt:  414595  Eth2TXInt:  45562
01/14/05 08:30:27 entries:  0010c986  Pkts:  1154479  Err:  3665  PPS:  769=
65 =20
Drop %:  0.31%  Eth3RXInt:  404918  Eth2TXInt:  45873
01/14/05 08:30:43 entries:  0010d8e5  Pkts:  1192416  Err:  4128  PPS:  794=
94 =20
Drop %:  0.34%  Eth3RXInt:  405126  Eth2TXInt:  43819
01/14/05 08:30:58 entries:  0010e633  Pkts:  1166668  Err:  3361  PPS:  777=
77 =20
Drop %:  0.28%  Eth3RXInt:  415004  Eth2TXInt:  44711
01/14/05 08:40:03 entries:  0012aad0  Pkts:  1138575  Err:  3211  PPS:  759=
05 =20
Drop %:  0.28%  Eth3RXInt:  373013  Eth2TXInt:  47718
01/14/05 08:40:18 entries:  0012c2e3  Pkts:  1158909  Err:  3481  PPS:  772=
60 =20
Drop %:  0.30%  Eth3RXInt:  366664  Eth2TXInt:  45401
01/14/05 08:40:33 entries:  0012d5fb  Pkts:  1155017  Err:  3674  PPS:  770=
01 =20
Drop %:  0.31%  Eth3RXInt:  389075  Eth2TXInt:  46785
01/14/05 08:40:48 entries:  00008aee  Pkts:  1033983  Err:  174485  PPS: =20
68932  Drop %:  16.87%  Eth3RXInt:  246160  Eth2TXInt:  60997

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart24040128.PuJ0tmka1N
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB595dqtjaBHGZBeURArZgAJsEpm5evhwsj26dMD9zrzRZzdAYnQCfYNuf
/FwmUlAZx1ly/oGN61Q6vak=
=NEZp
-----END PGP SIGNATURE-----

--nextPart24040128.PuJ0tmka1N--
