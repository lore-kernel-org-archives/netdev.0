From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Dump of TCP hang in established state
Date: 30 May 2003 00:00:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1054245634.711.57.camel@tux.rsn.bth.se>
References: <20030529.024114.78714066.davem@redhat.com>
	 <1054217010.757.39.camel@tux.rsn.bth.se>
	 <1054238230.709.1.camel@tux.rsn.bth.se>
	 <20030529.145433.35666641.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-qYql9ciHiNamFIMcnWJ9"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030529.145433.35666641.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-qYql9ciHiNamFIMcnWJ9
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2003-05-29 at 23:54, David S. Miller wrote:
>    From: Martin Josefsson <gandalf@wlug.westbo.se>
>    Date: 29 May 2003 21:57:11 +0200
>    
>    I've just tested 2.5-bk and I can still reproduce it.
> 
> Can you get a tcpdump trace at the sender side for the complete life
> of the connection for which the hang occurs?
> 
> There isn't much we can do about this without a trace.

I've already sent the trace twice to netdev, I've attached it again.
I can reproduce it quite easily, both with TCP_CORK and without.

-- 
/Martin

--=-qYql9ciHiNamFIMcnWJ9
Content-Disposition: attachment; filename=stall-57798-anon
Content-Type: text/plain; name=stall-57798-anon; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

16:02:08.643827 x.x.x.x.57798 > y.y.y.y.3632: S 1626991454:1626991454(0) wi=
n 5840 <mss 1460,sackOK,timestamp 1466330247 0,nop,wscale 3> (DF)
16:02:08.647286 y.y.y.y.3632 > x.x.x.x.57798: S 77827266:77827266(0) ack 16=
26991455 win 5696 <mss 1436,sackOK,timestamp 143345276 1466330247,nop,wscal=
e 0> (DF)
16:02:08.647330 x.x.x.x.57798 > y.y.y.y.3632: . ack 1 win 730 <nop,nop,time=
stamp 1466330250 143345276> (DF)
16:02:08.906471 x.x.x.x.57798 > y.y.y.y.3632: . 1:1425(1424) ack 1 win 730 =
<nop,nop,timestamp 1466330509 143345276> (DF)
16:02:08.906495 x.x.x.x.57798 > y.y.y.y.3632: . 1425:2849(1424) ack 1 win 7=
30 <nop,nop,timestamp 1466330509 143345276> (DF)
16:02:08.906517 x.x.x.x.57798 > y.y.y.y.3632: P 2849:4273(1424) ack 1 win 7=
30 <nop,nop,timestamp 1466330509 143345276> (DF)
16:02:08.910667 y.y.y.y.3632 > x.x.x.x.57798: . ack 1425 win 8544 <nop,nop,=
timestamp 143345302 1466330509> (DF)
16:02:08.910672 y.y.y.y.3632 > x.x.x.x.57798: . ack 2849 win 11392 <nop,nop=
,timestamp 143345302 1466330509> (DF)
16:02:08.911239 y.y.y.y.3632 > x.x.x.x.57798: . ack 4273 win 14240 <nop,nop=
,timestamp 143345302 1466330509> (DF)
16:02:09.060689 x.x.x.x.57798 > y.y.y.y.3632: . 4273:5697(1424) ack 1 win 7=
30 <nop,nop,timestamp 1466330664 143345302> (DF)
16:02:09.060714 x.x.x.x.57798 > y.y.y.y.3632: . 5697:7121(1424) ack 1 win 7=
30 <nop,nop,timestamp 1466330664 143345302> (DF)
16:02:09.060738 x.x.x.x.57798 > y.y.y.y.3632: P 7121:8545(1424) ack 1 win 7=
30 <nop,nop,timestamp 1466330664 143345302> (DF)
16:02:09.060754 x.x.x.x.57798 > y.y.y.y.3632: . 8545:9969(1424) ack 1 win 7=
30 <nop,nop,timestamp 1466330664 143345302> (DF)
16:02:09.060772 x.x.x.x.57798 > y.y.y.y.3632: . 9969:11393(1424) ack 1 win =
730 <nop,nop,timestamp 1466330664 143345302> (DF)
16:02:09.060785 x.x.x.x.57798 > y.y.y.y.3632: . 11393:12817(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330664 143345302> (DF)
16:02:09.064187 y.y.y.y.3632 > x.x.x.x.57798: . ack 7121 win 19936 <nop,nop=
,timestamp 143345317 1466330664> (DF)
16:02:09.064192 y.y.y.y.3632 > x.x.x.x.57798: . ack 5697 win 17088 <nop,nop=
,timestamp 143345317 1466330664> (DF)
16:02:09.064194 y.y.y.y.3632 > x.x.x.x.57798: . ack 8545 win 22784 <nop,nop=
,timestamp 143345317 1466330664> (DF)
16:02:09.064451 y.y.y.y.3632 > x.x.x.x.57798: . ack 9969 win 25632 <nop,nop=
,timestamp 143345317 1466330664> (DF)
16:02:09.064454 y.y.y.y.3632 > x.x.x.x.57798: . ack 11393 win 28480 <nop,no=
p,timestamp 143345317 1466330664> (DF)
16:02:09.064456 y.y.y.y.3632 > x.x.x.x.57798: . ack 12817 win 31328 <nop,no=
p,timestamp 143345317 1466330664> (DF)
16:02:09.170403 x.x.x.x.57798 > y.y.y.y.3632: . 12817:14241(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170418 x.x.x.x.57798 > y.y.y.y.3632: P 14241:15665(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170430 x.x.x.x.57798 > y.y.y.y.3632: . 15665:17089(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170451 x.x.x.x.57798 > y.y.y.y.3632: . 17089:18513(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170464 x.x.x.x.57798 > y.y.y.y.3632: P 18513:19937(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170482 x.x.x.x.57798 > y.y.y.y.3632: . 19937:21361(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170496 x.x.x.x.57798 > y.y.y.y.3632: . 21361:22785(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170513 x.x.x.x.57798 > y.y.y.y.3632: P 22785:24209(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170528 x.x.x.x.57798 > y.y.y.y.3632: . 24209:25633(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170546 x.x.x.x.57798 > y.y.y.y.3632: . 25633:27057(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.170560 x.x.x.x.57798 > y.y.y.y.3632: P 27057:28481(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330773 143345317> (DF)
16:02:09.174188 y.y.y.y.3632 > x.x.x.x.57798: . ack 14241 win 34176 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.174529 y.y.y.y.3632 > x.x.x.x.57798: . ack 15665 win 37024 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.174533 y.y.y.y.3632 > x.x.x.x.57798: . ack 17089 win 39872 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.174535 y.y.y.y.3632 > x.x.x.x.57798: . ack 18513 win 42720 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.175157 y.y.y.y.3632 > x.x.x.x.57798: . ack 19937 win 45568 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.175160 y.y.y.y.3632 > x.x.x.x.57798: . ack 21361 win 48416 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.175178 y.y.y.y.3632 > x.x.x.x.57798: . ack 22785 win 51264 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.175383 y.y.y.y.3632 > x.x.x.x.57798: . ack 24209 win 54112 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.175422 y.y.y.y.3632 > x.x.x.x.57798: . ack 25633 win 56960 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.175696 y.y.y.y.3632 > x.x.x.x.57798: . ack 27057 win 59808 <nop,no=
p,timestamp 143345328 1466330773> (DF)
16:02:09.175731 y.y.y.y.3632 > x.x.x.x.57798: . ack 28481 win 62656 <nop,no=
p,timestamp 143345329 1466330773> (DF)
16:02:09.178274 x.x.x.x.57798 > y.y.y.y.3632: . 28481:29905(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178302 x.x.x.x.57798 > y.y.y.y.3632: . 29905:31329(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178326 x.x.x.x.57798 > y.y.y.y.3632: P 31329:32753(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178374 x.x.x.x.57798 > y.y.y.y.3632: . 32753:34177(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178395 x.x.x.x.57798 > y.y.y.y.3632: . 34177:35601(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178415 x.x.x.x.57798 > y.y.y.y.3632: P 35601:37025(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178435 x.x.x.x.57798 > y.y.y.y.3632: . 37025:38449(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178453 x.x.x.x.57798 > y.y.y.y.3632: . 38449:39873(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178472 x.x.x.x.57798 > y.y.y.y.3632: P 39873:41297(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178490 x.x.x.x.57798 > y.y.y.y.3632: . 41297:42721(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178509 x.x.x.x.57798 > y.y.y.y.3632: . 42721:44145(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345328> (DF)
16:02:09.178528 x.x.x.x.57798 > y.y.y.y.3632: . 44145:45569(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330781 143345329> (DF)
16:02:09.181333 y.y.y.y.3632 > x.x.x.x.57798: . ack 29905 win 64080 <nop,no=
p,timestamp 143345329 1466330781> (DF)
16:02:09.182086 y.y.y.y.3632 > x.x.x.x.57798: . ack 31329 win 64080 <nop,no=
p,timestamp 143345329 1466330781> (DF)
16:02:09.182139 y.y.y.y.3632 > x.x.x.x.57798: . ack 32753 win 64080 <nop,no=
p,timestamp 143345329 1466330781> (DF)
16:02:09.182151 y.y.y.y.3632 > x.x.x.x.57798: . ack 35601 win 64080 <nop,no=
p,timestamp 143345329 1466330781> (DF)
16:02:09.182583 y.y.y.y.3632 > x.x.x.x.57798: . ack 38449 win 64080 <nop,no=
p,timestamp 143345329 1466330781> (DF)
16:02:09.182587 y.y.y.y.3632 > x.x.x.x.57798: . ack 41297 win 64080 <nop,no=
p,timestamp 143345329 1466330781> (DF)
16:02:09.183271 y.y.y.y.3632 > x.x.x.x.57798: . ack 44145 win 64080 <nop,no=
p,timestamp 143345329 1466330781> (DF)
16:02:09.215723 y.y.y.y.3632 > x.x.x.x.57798: . ack 45569 win 64080 <nop,no=
p,timestamp 143345333 1466330781> (DF)
16:02:09.330622 x.x.x.x.57798 > y.y.y.y.3632: . 45569:46993(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330645 x.x.x.x.57798 > y.y.y.y.3632: P 46993:48417(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330664 x.x.x.x.57798 > y.y.y.y.3632: . 48417:49841(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330678 x.x.x.x.57798 > y.y.y.y.3632: . 49841:51265(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330696 x.x.x.x.57798 > y.y.y.y.3632: P 51265:52689(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330709 x.x.x.x.57798 > y.y.y.y.3632: . 52689:54113(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330727 x.x.x.x.57798 > y.y.y.y.3632: . 54113:55537(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330740 x.x.x.x.57798 > y.y.y.y.3632: P 55537:56961(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330760 x.x.x.x.57798 > y.y.y.y.3632: . 56961:58385(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330775 x.x.x.x.57798 > y.y.y.y.3632: . 58385:59809(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330794 x.x.x.x.57798 > y.y.y.y.3632: P 59809:61233(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330806 x.x.x.x.57798 > y.y.y.y.3632: . 61233:62657(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345329> (DF)
16:02:09.330823 x.x.x.x.57798 > y.y.y.y.3632: . 62657:64081(1424) ack 1 win=
 730 <nop,nop,timestamp 1466330934 143345333> (DF)
16:02:09.333999 y.y.y.y.3632 > x.x.x.x.57798: . ack 48417 win 64080 <nop,no=
p,timestamp 143345344 1466330934> (DF)
16:02:09.334363 y.y.y.y.3632 > x.x.x.x.57798: . ack 51265 win 64080 <nop,no=
p,timestamp 143345344 1466330934> (DF)
16:02:09.334622 y.y.y.y.3632 > x.x.x.x.57798: . ack 54113 win 64080 <nop,no=
p,timestamp 143345344 1466330934> (DF)
16:02:09.335094 y.y.y.y.3632 > x.x.x.x.57798: . ack 56961 win 64080 <nop,no=
p,timestamp 143345344 1466330934> (DF)
16:02:09.335356 y.y.y.y.3632 > x.x.x.x.57798: . ack 59809 win 64080 <nop,no=
p,timestamp 143345344 1466330934> (DF)
16:02:09.335839 y.y.y.y.3632 > x.x.x.x.57798: . ack 62657 win 64080 <nop,no=
p,timestamp 143345345 1466330934> (DF)
16:02:09.375666 y.y.y.y.3632 > x.x.x.x.57798: . ack 64081 win 64080 <nop,no=
p,timestamp 143345349 1466330934> (DF)
16:02:09.438879 x.x.x.x.57798 > y.y.y.y.3632: P 64081:65505(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.438892 x.x.x.x.57798 > y.y.y.y.3632: . 65505:66929(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.438911 x.x.x.x.57798 > y.y.y.y.3632: . 66929:68353(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.438924 x.x.x.x.57798 > y.y.y.y.3632: P 68353:69777(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.438943 x.x.x.x.57798 > y.y.y.y.3632: . 69777:71201(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.438958 x.x.x.x.57798 > y.y.y.y.3632: . 71201:72625(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.438976 x.x.x.x.57798 > y.y.y.y.3632: P 72625:74049(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.438989 x.x.x.x.57798 > y.y.y.y.3632: . 74049:75473(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.439008 x.x.x.x.57798 > y.y.y.y.3632: . 75473:76897(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.439022 x.x.x.x.57798 > y.y.y.y.3632: . 76897:78321(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345344> (DF)
16:02:09.439041 x.x.x.x.57798 > y.y.y.y.3632: . 78321:79745(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345345> (DF)
16:02:09.439054 x.x.x.x.57798 > y.y.y.y.3632: P 79745:81169(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345345> (DF)
16:02:09.439071 x.x.x.x.57798 > y.y.y.y.3632: . 81169:82593(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331042 143345349> (DF)
16:02:09.443513 y.y.y.y.3632 > x.x.x.x.57798: . ack 66929 win 64080 <nop,no=
p,timestamp 143345355 1466331042> (DF)
16:02:09.443823 y.y.y.y.3632 > x.x.x.x.57798: . ack 69777 win 64080 <nop,no=
p,timestamp 143345355 1466331042> (DF)
16:02:09.444319 y.y.y.y.3632 > x.x.x.x.57798: . ack 72625 win 64080 <nop,no=
p,timestamp 143345355 1466331042> (DF)
16:02:09.444680 y.y.y.y.3632 > x.x.x.x.57798: . ack 75473 win 64080 <nop,no=
p,timestamp 143345355 1466331042> (DF)
16:02:09.444770 y.y.y.y.3632 > x.x.x.x.57798: . ack 78321 win 64080 <nop,no=
p,timestamp 143345355 1466331042> (DF)
16:02:09.444899 y.y.y.y.3632 > x.x.x.x.57798: . ack 81169 win 64080 <nop,no=
p,timestamp 143345355 1466331042> (DF)
16:02:09.445460 x.x.x.x.57798 > y.y.y.y.3632: . 82593:84017(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331048 143345355> (DF)
16:02:09.445481 x.x.x.x.57798 > y.y.y.y.3632: P 84017:85441(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331048 143345355> (DF)
16:02:09.445501 x.x.x.x.57798 > y.y.y.y.3632: . 85441:86865(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331048 143345355> (DF)
16:02:09.445514 x.x.x.x.57798 > y.y.y.y.3632: . 86865:88289(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331048 143345355> (DF)
16:02:09.445531 x.x.x.x.57798 > y.y.y.y.3632: P 88289:89713(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331048 143345355> (DF)
16:02:09.445583 x.x.x.x.57798 > y.y.y.y.3632: . 89713:91137(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331048 143345355> (DF)
16:02:09.445597 x.x.x.x.57798 > y.y.y.y.3632: . 91137:92561(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331049 143345355> (DF)
16:02:09.445616 x.x.x.x.57798 > y.y.y.y.3632: P 92561:93985(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331049 143345355> (DF)
16:02:09.445629 x.x.x.x.57798 > y.y.y.y.3632: . 93985:95409(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331049 143345355> (DF)
16:02:09.445650 x.x.x.x.57798 > y.y.y.y.3632: . 95409:96833(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331049 143345355> (DF)
16:02:09.445665 x.x.x.x.57798 > y.y.y.y.3632: P 96833:98257(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331049 143345355> (DF)
16:02:09.445683 x.x.x.x.57798 > y.y.y.y.3632: . 98257:99681(1424) ack 1 win=
 730 <nop,nop,timestamp 1466331049 143345355> (DF)
16:02:09.445695 x.x.x.x.57798 > y.y.y.y.3632: . 99681:101105(1424) ack 1 wi=
n 730 <nop,nop,timestamp 1466331049 143345355> (DF)
16:02:09.451822 y.y.y.y.3632 > x.x.x.x.57798: . ack 84017 win 64080 <nop,no=
p,timestamp 143345356 1466331042> (DF)
16:02:09.452573 y.y.y.y.3632 > x.x.x.x.57798: . ack 86865 win 64080 <nop,no=
p,timestamp 143345356 1466331048> (DF)
16:02:09.452740 y.y.y.y.3632 > x.x.x.x.57798: . ack 89713 win 64080 <nop,no=
p,timestamp 143345356 1466331048> (DF)
16:02:09.452989 y.y.y.y.3632 > x.x.x.x.57798: . ack 92561 win 64080 <nop,no=
p,timestamp 143345356 1466331048> (DF)
16:02:09.453352 y.y.y.y.3632 > x.x.x.x.57798: . ack 95409 win 64080 <nop,no=
p,timestamp 143345356 1466331049> (DF)
16:02:09.454195 y.y.y.y.3632 > x.x.x.x.57798: . ack 98257 win 64080 <nop,no=
p,timestamp 143345356 1466331049> (DF)
16:02:09.454400 y.y.y.y.3632 > x.x.x.x.57798: . ack 101105 win 64080 <nop,n=
op,timestamp 143345356 1466331049> (DF)
16:02:09.597688 x.x.x.x.57798 > y.y.y.y.3632: P 101105:102529(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597702 x.x.x.x.57798 > y.y.y.y.3632: . 102529:103953(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597721 x.x.x.x.57798 > y.y.y.y.3632: . 103953:105377(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597734 x.x.x.x.57798 > y.y.y.y.3632: P 105377:106801(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597755 x.x.x.x.57798 > y.y.y.y.3632: . 106801:108225(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597768 x.x.x.x.57798 > y.y.y.y.3632: . 108225:109649(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597787 x.x.x.x.57798 > y.y.y.y.3632: . 109649:111073(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597800 x.x.x.x.57798 > y.y.y.y.3632: . 111073:112497(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597818 x.x.x.x.57798 > y.y.y.y.3632: P 112497:113921(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597832 x.x.x.x.57798 > y.y.y.y.3632: . 113921:115345(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597849 x.x.x.x.57798 > y.y.y.y.3632: . 115345:116769(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597862 x.x.x.x.57798 > y.y.y.y.3632: P 116769:118193(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597903 x.x.x.x.57798 > y.y.y.y.3632: . 118193:119617(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.597915 x.x.x.x.57798 > y.y.y.y.3632: . 119617:121041(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331201 143345356> (DF)
16:02:09.610011 y.y.y.y.3632 > x.x.x.x.57798: . ack 103953 win 64080 <nop,n=
op,timestamp 143345372 1466331201> (DF)
16:02:09.610486 y.y.y.y.3632 > x.x.x.x.57798: . ack 106801 win 64080 <nop,n=
op,timestamp 143345372 1466331201> (DF)
16:02:09.610899 y.y.y.y.3632 > x.x.x.x.57798: . ack 109649 win 64080 <nop,n=
op,timestamp 143345372 1466331201> (DF)
16:02:09.611921 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345372 1466331201,nop,nop,sack sack 1 {113921:115345} > (DF=
)
16:02:09.611944 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345372 1466331201,nop,nop,sack sack 1 {113921:116769} > (DF=
)
16:02:09.611963 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345372 1466331201,nop,nop,sack sack 1 {113921:118193} > (DF=
)
16:02:09.611996 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345372 1466331201,nop,nop,sack sack 1 {113921:119617} > (DF=
)
16:02:09.703860 x.x.x.x.57798 > y.y.y.y.3632: P 121041:122465(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.703873 x.x.x.x.57798 > y.y.y.y.3632: . 122465:123889(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.703892 x.x.x.x.57798 > y.y.y.y.3632: . 123889:125313(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.703908 x.x.x.x.57798 > y.y.y.y.3632: P 125313:126737(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.703926 x.x.x.x.57798 > y.y.y.y.3632: . 126737:128161(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.703939 x.x.x.x.57798 > y.y.y.y.3632: . 128161:129585(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.705559 x.x.x.x.57798 > y.y.y.y.3632: P 129585:131009(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.705565 x.x.x.x.57798 > y.y.y.y.3632: . 131009:132433(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.705570 x.x.x.x.57798 > y.y.y.y.3632: . 132433:133857(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.705574 x.x.x.x.57798 > y.y.y.y.3632: P 133857:135281(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.705578 x.x.x.x.57798 > y.y.y.y.3632: . 135281:136705(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331307 143345372> (DF)
16:02:09.714200 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345382 1466331201,nop,nop,sack sack 2 {121041:122465}{11392=
1:119617} > (DF)
16:02:09.714499 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345382 1466331201,nop,nop,sack sack 2 {121041:123889}{11392=
1:119617} > (DF)
16:02:09.714698 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345382 1466331201,nop,nop,sack sack 2 {121041:125313}{11392=
1:119617} > (DF)
16:02:09.714772 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345382 1466331201,nop,nop,sack sack 2 {121041:126737}{11392=
1:119617} > (DF)
16:02:09.715358 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345382 1466331201,nop,nop,sack sack 2 {121041:128161}{11392=
1:119617} > (DF)
16:02:09.715361 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345382 1466331201,nop,nop,sack sack 2 {121041:129585}{11392=
1:119617} > (DF)
16:02:09.715550 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345382 1466331201,nop,nop,sack sack 2 {121041:131009}{11392=
1:119617} > (DF)
16:02:09.715552 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345382 1466331201,nop,nop,sack sack 2 {121041:132433}{11392=
1:119617} > (DF)
16:02:09.715672 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345383 1466331201,nop,nop,sack sack 2 {121041:133857}{11392=
1:119617} > (DF)
16:02:09.715675 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345383 1466331201,nop,nop,sack sack 2 {121041:135281}{11392=
1:119617} > (DF)
16:02:09.715677 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345383 1466331201,nop,nop,sack sack 2 {121041:136705}{11392=
1:119617} > (DF)
16:02:09.808712 x.x.x.x.57798 > y.y.y.y.3632: . 136705:138129(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331412 143345382> (DF)
16:02:09.808735 x.x.x.x.57798 > y.y.y.y.3632: P 138129:139548(1419) ack 1 w=
in 730 <nop,nop,timestamp 1466331412 143345382> (DF)
16:02:09.808784 x.x.x.x.57798 > y.y.y.y.3632: . 111073:112497(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331412 143345382> (DF)
16:02:09.808813 x.x.x.x.57798 > y.y.y.y.3632: P 112497:113921(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331412 143345382> (DF)
16:02:09.808838 x.x.x.x.57798 > y.y.y.y.3632: . 119617:121041(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466331412 143345383> (DF)
16:02:09.822496 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345393 1466331201,nop,nop,sack sack 2 {121041:138129}{11392=
1:119617} > (DF)
16:02:09.822498 y.y.y.y.3632 > x.x.x.x.57798: . ack 111073 win 64080 <nop,n=
op,timestamp 143345393 1466331201,nop,nop,sack sack 2 {121041:139548}{11392=
1:119617} > (DF)
16:04:24.936079 x.x.x.x.57798 > y.y.y.y.3632: . 111073:112497(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466466560 143345393> (DF)
16:04:24.938582 y.y.y.y.3632 > x.x.x.x.57798: . ack 112497 win 62656 <nop,n=
op,timestamp 143358906 1466466560,nop,nop,sack sack 2 {121041:139548}{11392=
1:119617} > (DF)
16:04:24.939909 x.x.x.x.57798 > y.y.y.y.3632: P 112497:113921(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466466563 143358906> (DF)
16:04:24.939937 x.x.x.x.57798 > y.y.y.y.3632: . 119617:121041(1424) ack 1 w=
in 730 <nop,nop,timestamp 1466466563 143358906> (DF)
16:04:24.942568 y.y.y.y.3632 > x.x.x.x.57798: . ack 119617 win 55536 <nop,n=
op,timestamp 143358906 1466466563,nop,nop,sack sack 1 {121041:139548} > (DF=
)
16:04:24.942573 y.y.y.y.3632 > x.x.x.x.57798: . ack 139548 win 46992 <nop,n=
op,timestamp 143358906 1466466563> (DF)
16:04:25.038755 y.y.y.y.3632 > x.x.x.x.57798: P 1:1166(1165) ack 139548 win=
 64080 <nop,nop,timestamp 143358916 1466466563> (DF)
16:04:25.038765 y.y.y.y.3632 > x.x.x.x.57798: F 1166:1166(0) ack 139548 win=
 64080 <nop,nop,timestamp 143358916 1466466563> (DF)
16:04:25.038893 x.x.x.x.57798 > y.y.y.y.3632: . ack 1166 win 1019 <nop,nop,=
timestamp 1466466662 143358916> (DF)
16:04:25.039286 x.x.x.x.57798 > y.y.y.y.3632: F 139548:139548(0) ack 1167 w=
in 1019 <nop,nop,timestamp 1466466663 143358916> (DF)
16:04:25.041470 y.y.y.y.3632 > x.x.x.x.57798: . ack 139549 win 64080 <nop,n=
op,timestamp 143358916 1466466663> (DF)

--=-qYql9ciHiNamFIMcnWJ9--
