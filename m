From: Ingo Molnar <mingo@elte.hu>
Subject: Re: e1000e regression (interface hang) with latest
	-git
Date: Wed, 21 Jan 2009 19:03:44 +0100
Message-ID: <20090121180344.GA13675@elte.hu>
References: <20090121102840.GA24967@elte.hu>
	<8DD2590731AB5D4C9DBF71A877482A900DABEA6F@orsmsx509.amr.corp.intel.com>
	<20090121175158.GA7302@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20090121175158.GA7302@elte.hu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


* Ingo Molnar <mingo@elte.hu> wrote:

> The same point remains though: it worked before (and works fine with a 
> distro kernel, 2.6.28-0.140.rc9.git1.fc11.x86_64) and doesnt work with 
> latest -git.
> 
> I'll capture some debug data and send it to you.

find attached the debug data:

  ethtool.dump.eth0.before
  ethtool.dump.eth0.after
  ethtool.dump.eth0.after2
  boot.log
  config

the 'before' dump is before the hang, shortly after bootup. It also 
includes 'ifconfig eth0' output.

the 'after' dump is after the hang - while the interface is hung.

'after2' dump is after a 'service network restart' - which brought the 
interface back.

Note if i wait long enough (half an hour or so), then not even 'service 
network restart' will bring back the device.

The kernel i tested is: v2.6.29-rc2-13-gf3b8436

	Ingo


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ethtool.dump.eth0.before"

eth0      Link encap:Ethernet  HWaddr 00:30:48:C3:7D:C2  
          inet addr:10.0.1.20  Bcast:10.0.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:242484 errors:0 dropped:0 overruns:0 frame:0
          TX packets:52762 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:356864517 (340.3 MiB)  TX bytes:10818221 (10.3 MiB)
          Memory:fbea0000-fbec0000 

Offset	Values
--------	-----
000:	 41 02 d0 18 83 07 08 00 01 0c 18 91 00 38 2a 18
010:	 00 00 00 80 04 06 00 00 00 81 00 00 02 83 06 07
020:	 22 00 0e 00 30 00 00 00 b7 cf b8 fc 00 00 00 00
030:	 18 47 00 00 02 00 00 00 02 00 00 00 0f 0f 00 80
040:	 0f 0f 00 80 0f 0f 00 00 0f 0f 00 80 81 00 00 00
050:	 81 00 00 00 04 00 00 00 04 00 00 00 01 07 00 00
060:	 00 00 00 00 00 00 00 00 01 80 c2 00 00 01 00 00
070:	 ff ff 00 00 50 7a 00 80 60 7a 00 00 00 00 00 00
080:	 02 80 04 04 00 23 00 00 ee 05 00 00 00 00 00 00
090:	 02 00 f7 01 00 00 00 00 fa f0 03 a5 40 08 01 00
0a0:	 08 10 60 00 04 18 0c 08 00 00 00 00 00 00 00 00
0b0:	 00 00 00 00 00 00 00 00 f9 8a 1f 71 08 00 00 00
0c0:	 0c 00 04 02 0d 00 60 00 a0 01 00 00 00 00 00 00
0d0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0e0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0f0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
100:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
110:	 00 00 00 00 00 00 00 00 d1 04 00 00 00 00 00 00
120:	 d1 04 00 00 00 00 00 00 0a 00 00 00 78 20 00 00
130:	 50 00 00 00 73 00 00 00 b2 01 00 00 ff 6a 04 00
140:	 f6 8d 04 00 07 00 00 00 00 00 00 00 04 fc 00 00
150:	 7a c6 3f 1a 00 00 00 00 4f a5 d0 00 00 00 00 00
160:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
170:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
180:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
190:	 fb 8d 04 00 a6 05 01 00 05 00 00 00 e8 e1 00 00
1a0:	 7b 00 00 00 64 00 00 00 00 01 00 00 38 18 00 00
1b0:	 00 00 00 00 03 00 00 00 2e 08 00 00 d0 69 01 00
1c0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1d0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1e0:	 00 00 00 00 02 00 00 02 02 00 00 02 02 00 00 02
1f0:	 02 00 00 02 fe ff 07 00 fe ff 07 00 fe ff 07 00
200:	 fe ff 07 00 00 80 16 b5 00 b0 4d b3 00 40 cd b3
210:	 00 d0 51 b5 04 00 00 00 04 00 00 00 04 00 00 00
220:	 04 00 00 00 00 10 00 00 00 10 00 00 00 10 00 00
230:	 00 10 00 00 76 00 00 00 f8 00 00 00 c0 00 00 00
240:	 23 00 00 00 74 00 00 00 f6 00 00 00 be 00 00 00
250:	 21 00 00 00 10 08 01 02 10 08 01 02 10 08 01 02
260:	 10 08 01 02 d0 03 00 00 d0 03 0b 01 d0 03 00 00
270:	 d0 03 00 00 3d 00 00 00 01 03 07 01 31 00 00 00
280:	 01 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
290:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2a0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2b0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2c0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 30 48 c3
2d0:	 01 00 5e 00 00 00 00 00 00 00 00 00 00 00 00 00
2e0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2f0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
300:	 00 00 00 00 00 00 00 00 00 00 00 00 7d c2 00 80
310:	 00 01 00 80 00 00 00 80 00 00 00 80 00 00 00 80
320:	 00 00 00 80 00 00 00 80 00 00 00 80 00 00 00 80
330:	 00 00 00 80 00 00 00 80 00 00 00 80 00 00 00 80
340:	 00 00 00 80 00 00 00 80 00 00 00 80 00 f0 4d b3
350:	 00 a0 4d b3 00 40 4e b3 00 20 cb b3 04 00 00 00
360:	 04 00 00 00 04 00 00 00 04 00 00 00 00 10 00 00
370:	 00 10 00 00 00 10 00 00 00 10 00 00 66 00 00 00
380:	 9f 00 00 00 c0 00 00 00 ed 00 00 00 66 00 00 00
390:	 a0 00 00 00 c0 00 00 00 ed 00 00 00 00 00 00 02
3a0:	 00 00 00 02 00 00 00 02 00 00 00 02 00 00 00 00
3b0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
3c0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 22 00 00
3d0:	 00 22 00 00 00 22 00 00 00 22 00 00 00 00 00 00
3e0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
3f0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 30 48 c3
400:	 7d c2 00 19 d1 01 f5 55 08 00 45 00 05 dc e4 ac
410:	 40 00 40 06 3a 4c 0a 00 01 10 0a 00 01 14 b2 42
420:	 0e 30 fc 62 24 d4 f5 72 88 ad 80 10 00 2e 21 6c
430:	 00 00 01 01 08 0a 1b c0 c8 3f ff ff 19 e2 29 3b
440:	 0a 65 78 74 65 72 6e 20 69 6e 74 20 64 6f 5f 73
450:	 69 67 61 6c 74 73 74 61 63 6b 28 63 6f 6e 73 74
460:	 20 73 74 61 63 6b 5f 74 20 2a 2c 20 73 74 61 63
470:	 6b 5f 74 20 2a 2c 20 75 6e 73 69 67 01 00 00 00
480:	 0b 00 00 00 0f 00 00 00 0f 00 00 00 03 00 00 00
490:	 0f 00 00 00 0e 00 00 00 09 00 00 00 0c 00 00 00
4a0:	 02 00 00 00 0e 00 00 00 0f 00 00 00 05 00 00 00
4b0:	 0f 00 00 00 07 00 00 00 03 00 00 00 09 00 00 00
4c0:	 07 00 00 00 06 00 00 00 03 00 00 00 0c 00 00 00
4d0:	 01 00 00 00 07 00 00 00 0b 00 00 00 09 00 00 00
4e0:	 05 00 00 00 05 00 00 00 0d 00 00 00 07 00 00 00
4f0:	 0a 00 00 00 0f 00 00 00 0f 00 00 00 04 00 00 00
500:	 05 00 00 00 0e 00 00 00 0f 00 00 00 02 00 00 00
510:	 0c 00 00 00 0c 00 00 00 0a 00 00 00 04 00 00 00
520:	 0b 00 00 00 07 00 00 00 03 00 00 00 0d 00 00 00
530:	 07 00 00 00 0f 00 00 00 01 00 00 00 0f 00 00 00
540:	 07 00 00 00 05 00 00 00 0f 00 00 00 0d 00 00 00
550:	 0b 00 00 00 0a 00 00 00 02 00 00 00 07 00 00 00
560:	 07 00 00 00 0b 00 00 00 07 00 00 00 00 00 00 00
570:	 06 00 00 00 06 00 00 00 0b 00 00 00 0f 00 00 00
580:	 06 00 00 00 0f 00 00 00 01 00 00 00 0f 00 00 00
590:	 02 00 00 00 0e 00 00 00 07 00 00 00 0c 00 00 00
5a0:	 06 00 00 00 0f 00 00 00 0f 00 00 00 03 00 00 00
5b0:	 05 00 00 00 06 00 00 00 0d 00 00 00 0e 00 00 00
5c0:	 0b 00 00 00 0b 00 00 00 07 00 00 00 09 00 00 00
5d0:	 09 00 00 00 0f 00 00 00 06 00 00 00 0d 00 00 00
5e0:	 07 00 00 00 0f 00 00 00 0f 00 00 00 0c 00 00 00
5f0:	 07 00 00 00 02 00 00 00 0f 00 00 00 07 00 00 00
600:	 06 00 00 00 07 00 00 00 06 00 00 00 0c 00 00 00
610:	 02 00 00 00 07 00 00 00 03 00 00 00 0f 00 00 00
620:	 02 00 00 00 05 00 00 00 0f 00 00 00 0c 00 00 00
630:	 0d 00 00 00 0c 00 00 00 0f 00 00 00 08 00 00 00
640:	 0d 00 00 00 0f 00 00 00 0f 00 00 00 0d 00 00 00
650:	 07 00 00 00 0b 00 00 00 07 00 00 00 06 00 00 00
660:	 0d 00 00 00 0f 00 00 00 0f 00 00 00 0f 00 00 00
670:	 03 00 00 00 0f 00 00 00 0f 00 00 00 c3 77 ba 0d
680:	 f6 17 87 f5 cb 15 93 b5 e0 27 56 cc 4d 3b ca e1
690:	 bb 32 ef a2 fc 3b ff ff 5f fd bf fe e7 6a eb 5e
6a0:	 ff 29 0e 13 bd ed 7b dd da b8 84 91 39 f7 1c 7e
6b0:	 7f ae 57 ed f2 f7 7b ad fb fe ee b3 c7 2b 85 b4
6c0:	 de 65 f7 b7 df de 6b fd fb c6 57 e2 59 71 5a f6
6d0:	 39 e0 fe ee d9 37 ec ff fa fe e3 6c e4 13 59 ff
6e0:	 f2 8f 46 ef 4f 7f e0 d7 77 7c ec f6 e5 7d ff df
6f0:	 b9 ce 4a b9 e9 77 3b 2f de dd df df e5 49 28 6f
700:	 ea 2f 17 f5 7d ff cd 4e ce ff f6 f5 39 d3 82 e5
710:	 db ef 7e 21 e1 57 fe d7 c3 f5 cf 9f 3d f1 7e 47
720:	 cf ff 65 f0 c7 35 ab ef f3 fe 9d d5 e1 06 dc ae
730:	 df f5 5f ab 6f b9 dc ff fc 67 bf ac f9 c4 dc f4
740:	 98 fe 5e 08 ff 1b f7 df d6 1c ef e7 4b 7d a3 65
750:	 7a 62 67 a6 e1 43 31 ef 6a 89 66 ef 58 af 75 f7
760:	 f8 ee c7 a7 ed f7 e3 fd da ed fe cb 8b fb fa fe
770:	 ed 74 46 df b4 87 3b d7 f1 fd bf 42 c3 b1 b4 3f
780:	 78 b0 4e ec df 8b bb 77 7f ef d7 f1 ca c7 bb db
790:	 6a 3f 38 d0 df 7f ec b1 d4 e6 84 ff c8 95 38 8b
7a0:	 5c e0 55 e6 af 5d f8 df 78 2f df fb fd 9a 19 f6
7b0:	 d5 fc ae eb b7 ff 09 fe de 75 16 c9 7a 5e 87 d4
7c0:	 f8 fb bf b4 bf b6 f9 7d f6 fd cf 8b ec 9d 7a 36
7d0:	 9b 7c 57 2b 9d f6 0f ff 70 ff fc c7 65 ed 55 47
7e0:	 6f dd 8c ab f7 7e af ff 7a 7f fe 5f bb fe bc 7e
7f0:	 b9 2d 6d 6c f3 e7 6f 9f 6f 73 6e a5 ec 03 68 bc
800:	 d7 1b 5b a9 91 33 ea e5 e5 54 fb ef 68 f3 5d a7
810:	 7d 9c cb ea df f3 d2 ff da 7d 79 7c ec f5 e3 f5
820:	 6a ee 42 42 aa a0 fb be de 3c ff a7 ad 41 f9 fb
830:	 ed 2f 5d ce 59 f7 fb dd ff fd 7f 8d ed 08 da 27
840:	 db 39 ee d2 df 9f 0f bd db b7 eb bf 67 41 5c a4
850:	 9a 7d ff ec 6f f6 3f ab 8a fb ef 7b fa eb 31 5e
860:	 7e 77 6e bf df c6 e9 ef eb 3f f5 ad d3 57 dc bc
870:	 f1 65 cb 69 58 47 cf dd fa ac d7 28 00 00 00 00
880:	 00 00 00 00 00 00 00 00 00 00 00 00 d4 15 00 00
890:	 94 16 00 00 94 16 00 00 00 00 00 00


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ethtool.dump.eth0.after"

Offset	Values
--------	-----
000:	 41 02 d0 18 83 07 08 00 01 0c 18 91 00 38 2a 18
010:	 00 00 00 80 04 06 00 00 00 81 00 00 02 83 06 07
020:	 22 00 0e 00 30 00 00 00 f6 7e 94 f0 00 00 00 00
030:	 18 47 00 00 00 00 00 00 00 00 00 00 0f 0f 00 80
040:	 0f 0f 00 80 0f 0f 00 00 0f 0f 00 80 81 00 00 00
050:	 81 00 00 00 04 00 00 00 04 00 00 00 08 00 00 00
060:	 00 00 00 00 00 00 00 00 01 80 c2 00 00 01 00 00
070:	 ff ff 00 00 50 7a 00 80 60 7a 00 00 00 00 00 00
080:	 02 80 04 04 00 23 00 00 ee 05 00 00 00 00 00 00
090:	 02 00 f7 01 00 00 00 00 fa f0 03 a5 40 08 01 00
0a0:	 08 10 60 00 04 18 0c 08 00 00 00 00 00 00 00 00
0b0:	 00 00 00 00 00 00 00 00 f9 8a 1f 71 08 00 00 00
0c0:	 0c 00 04 02 0d 00 60 00 a0 01 00 00 00 00 00 00
0d0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0e0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0f0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
100:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
110:	 00 00 00 00 02 00 00 00 a3 08 00 00 02 00 00 00
120:	 a2 08 00 00 00 00 00 00 36 00 00 00 a7 31 00 00
130:	 94 00 00 00 b7 00 00 00 7d 02 00 00 86 03 07 00
140:	 2b 39 07 00 33 00 00 00 00 00 00 00 8b 85 01 00
150:	 af 2c ab 29 00 00 00 00 bb c4 32 01 00 00 00 00
160:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
170:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
180:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
190:	 39 39 07 00 d0 96 01 00 06 00 00 00 d2 5f 01 00
1a0:	 bf 00 00 00 a7 00 00 00 b7 01 00 00 96 22 00 00
1b0:	 00 00 00 00 03 00 00 00 bd 0b 00 00 76 2a 02 00
1c0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1d0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1e0:	 00 00 00 00 02 00 00 02 02 00 00 02 02 00 00 02
1f0:	 02 00 00 02 fe ff 07 00 fe ff 07 00 fe ff 07 00
200:	 fe ff 07 00 00 80 16 b5 00 b0 4d b3 00 40 cd b3
210:	 00 d0 51 b5 04 00 00 00 04 00 00 00 04 00 00 00
220:	 04 00 00 00 00 10 00 00 00 10 00 00 00 10 00 00
230:	 00 10 00 00 11 00 00 00 4e 00 00 00 49 00 00 00
240:	 87 00 00 00 0f 00 00 00 4c 00 00 00 47 00 00 00
250:	 85 00 00 00 10 08 01 02 10 08 01 02 10 08 01 02
260:	 10 08 01 02 d0 03 00 00 d0 03 00 00 d0 03 00 00
270:	 d0 03 00 00 2a 00 00 00 31 00 00 00 31 00 00 00
280:	 31 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
290:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2a0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2b0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2c0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 30 48 c3
2d0:	 01 00 5e 00 00 00 00 00 00 00 00 00 00 00 00 00
2e0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2f0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
300:	 00 00 00 00 00 00 00 00 00 00 00 00 7d c2 00 80
310:	 00 01 00 80 00 00 00 80 00 00 00 80 00 00 00 80
320:	 00 00 00 80 00 00 00 80 00 00 00 80 00 00 00 80
330:	 00 00 00 80 00 00 00 80 00 00 00 80 00 00 00 80
340:	 00 00 00 80 00 00 00 80 00 00 00 80 00 f0 4d b3
350:	 00 a0 4d b3 00 40 4e b3 00 20 cb b3 04 00 00 00
360:	 04 00 00 00 04 00 00 00 04 00 00 00 00 10 00 00
370:	 00 10 00 00 00 10 00 00 00 10 00 00 3f 00 00 00
380:	 31 00 00 00 df 00 00 00 58 00 00 00 83 00 00 00
390:	 61 00 00 00 08 00 00 00 7f 00 00 00 00 00 00 02
3a0:	 00 00 00 02 00 00 00 02 00 00 00 02 00 00 00 00
3b0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
3c0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 22 00 00
3d0:	 00 22 00 00 00 22 00 00 00 22 00 00 00 00 00 00
3e0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
3f0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 30 48 c3
400:	 7d c2 00 19 d1 01 f5 55 08 00 45 00 00 3c fb 9a
410:	 40 00 40 06 28 fe 0a 00 01 10 0a 00 01 14 b6 b3
420:	 0e 30 87 12 f5 a6 00 00 00 00 a0 02 16 d0 ff b3
430:	 00 00 02 04 05 b4 04 02 08 0a 1b c3 bd f8 00 00
440:	 00 00 01 03 03 07 4a 00 06 04 00 00 4a 00 06 04
450:	 00 00 00 00 32 32 41 52 47 56 30 30 30 30 30 30
460:	 35 61 2f 6f 70 74 2f 63 72 6f 73 73 74 6f 6f 6c
470:	 2f 67 63 63 2d 34 2e 32 2e 32 2d 67 01 00 00 00
480:	 0b 00 00 00 0f 00 00 00 0f 00 00 00 03 00 00 00
490:	 0f 00 00 00 0e 00 00 00 09 00 00 00 0c 00 00 00
4a0:	 02 00 00 00 0e 00 00 00 0f 00 00 00 05 00 00 00
4b0:	 0f 00 00 00 07 00 00 00 03 00 00 00 09 00 00 00
4c0:	 07 00 00 00 06 00 00 00 03 00 00 00 0c 00 00 00
4d0:	 01 00 00 00 07 00 00 00 0b 00 00 00 09 00 00 00
4e0:	 05 00 00 00 05 00 00 00 0d 00 00 00 07 00 00 00
4f0:	 0a 00 00 00 0f 00 00 00 0f 00 00 00 04 00 00 00
500:	 05 00 00 00 0e 00 00 00 0f 00 00 00 02 00 00 00
510:	 0c 00 00 00 0c 00 00 00 0a 00 00 00 04 00 00 00
520:	 0b 00 00 00 07 00 00 00 03 00 00 00 0d 00 00 00
530:	 07 00 00 00 0f 00 00 00 01 00 00 00 0f 00 00 00
540:	 07 00 00 00 05 00 00 00 0f 00 00 00 0d 00 00 00
550:	 0b 00 00 00 0a 00 00 00 02 00 00 00 07 00 00 00
560:	 07 00 00 00 0b 00 00 00 07 00 00 00 00 00 00 00
570:	 06 00 00 00 06 00 00 00 0b 00 00 00 0f 00 00 00
580:	 06 00 00 00 0f 00 00 00 01 00 00 00 0f 00 00 00
590:	 02 00 00 00 0e 00 00 00 07 00 00 00 0c 00 00 00
5a0:	 06 00 00 00 0f 00 00 00 0f 00 00 00 03 00 00 00
5b0:	 05 00 00 00 06 00 00 00 0d 00 00 00 0e 00 00 00
5c0:	 0b 00 00 00 0b 00 00 00 07 00 00 00 09 00 00 00
5d0:	 09 00 00 00 0f 00 00 00 06 00 00 00 0d 00 00 00
5e0:	 07 00 00 00 0f 00 00 00 0f 00 00 00 0c 00 00 00
5f0:	 07 00 00 00 02 00 00 00 0f 00 00 00 07 00 00 00
600:	 06 00 00 00 07 00 00 00 06 00 00 00 0c 00 00 00
610:	 02 00 00 00 07 00 00 00 03 00 00 00 0f 00 00 00
620:	 02 00 00 00 05 00 00 00 0f 00 00 00 0c 00 00 00
630:	 0d 00 00 00 0c 00 00 00 0f 00 00 00 08 00 00 00
640:	 0d 00 00 00 0f 00 00 00 0f 00 00 00 0d 00 00 00
650:	 07 00 00 00 0b 00 00 00 07 00 00 00 06 00 00 00
660:	 0d 00 00 00 0f 00 00 00 0f 00 00 00 0f 00 00 00
670:	 03 00 00 00 0f 00 00 00 0f 00 00 00 c3 77 ba 0d
680:	 f6 17 87 f5 cb 15 93 b5 e0 27 56 cc 4d 3b ca e1
690:	 bb 32 ef a2 fc 3b ff ff 5f fd bf fe e7 6a eb 5e
6a0:	 ff 29 0e 13 bd ed 7b dd da b8 84 91 39 f7 1c 7e
6b0:	 7f ae 57 ed f2 f7 7b ad fb fe ee b3 c7 2b 85 b4
6c0:	 de 65 f7 b7 df de 6b fd fb c6 57 e2 59 71 5a f6
6d0:	 39 e0 fe ee d9 37 ec ff fa fe e3 6c e4 13 59 ff
6e0:	 f2 8f 46 ef 4f 7f e0 d7 77 7c ec f6 e5 7d ff df
6f0:	 b9 ce 4a b9 e9 77 3b 2f de dd df df e5 49 28 6f
700:	 ea 2f 17 f5 7d ff cd 4e ce ff f6 f5 39 d3 82 e5
710:	 db ef 7e 21 e1 57 fe d7 c3 f5 cf 9f 3d f1 7e 47
720:	 cf ff 65 f0 c7 35 ab ef f3 fe 9d d5 e1 06 dc ae
730:	 df f5 5f ab 6f b9 dc ff fc 67 bf ac f9 c4 dc f4
740:	 98 fe 5e 08 ff 1b f7 df d6 1c ef e7 4b 7d a3 65
750:	 7a 62 67 a6 e1 43 31 ef 6a 89 66 ef 58 af 75 f7
760:	 f8 ee c7 a7 ed f7 e3 fd da ed fe cb 8b fb fa fe
770:	 ed 74 46 df b4 87 3b d7 f1 fd bf 42 c3 b1 b4 3f
780:	 78 b0 4e ec df 8b bb 77 7f ef d7 f1 ca c7 bb db
790:	 6a 3f 38 d0 df 7f ec b1 d4 e6 84 ff c8 95 38 8b
7a0:	 5c e0 55 e6 af 5d f8 df 78 2f df fb fd 9a 19 f6
7b0:	 d5 fc ae eb b7 ff 09 fe de 75 16 c9 7a 5e 87 d4
7c0:	 f8 fb bf b4 bf b6 f9 7d f6 fd cf 8b ec 9d 7a 36
7d0:	 9b 7c 57 2b 9d f6 0f ff 70 ff fc c7 65 ed 55 47
7e0:	 6f dd 8c ab f7 7e af ff 7a 7f fe 5f bb fe bc 7e
7f0:	 b9 2d 6d 6c f3 e7 6f 9f 6f 73 6e a5 ec 03 68 bc
800:	 d7 1b 5b a9 91 33 ea e5 e5 54 fb ef 68 f3 5d a7
810:	 7d 9c cb ea df f3 d2 ff da 7d 79 7c ec f5 e3 f5
820:	 6a ee 42 42 aa a0 fb be de 3c ff a7 ad 41 f9 fb
830:	 ed 2f 5d ce 59 f7 fb dd ff fd 7f 8d ed 08 da 27
840:	 db 39 ee d2 df 9f 0f bd db b7 eb bf 67 41 5c a4
850:	 9a 7d ff ec 6f f6 3f ab 8a fb ef 7b fa eb 31 5e
860:	 7e 77 6e bf df c6 e9 ef eb 3f f5 ad d3 57 dc bc
870:	 f1 65 cb 69 58 47 cf dd fa ac d7 28 00 00 00 00
880:	 00 00 00 00 00 00 00 00 00 00 00 00 50 13 00 00
890:	 5c 13 00 00 5c 13 00 00 00 00 00 00

eth0      Link encap:Ethernet  HWaddr 00:30:48:C3:7D:C2  
          inet addr:10.0.1.20  Bcast:10.0.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:473159 errors:0 dropped:0 overruns:0 frame:0
          TX packets:99650 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:696821457 (664.5 MiB)  TX bytes:19700507 (18.7 MiB)
          Memory:fbea0000-fbec0000 


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ethtool.dump.eth0.after2"

eth0      Link encap:Ethernet  HWaddr 00:30:48:C3:7D:C2  
          inet addr:10.0.1.20  Bcast:10.0.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:474842 errors:0 dropped:0 overruns:0 frame:0
          TX packets:99949 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:699255186 (666.8 MiB)  TX bytes:19779323 (18.8 MiB)
          Memory:fbea0000-fbec0000 

Offset	Values
--------	-----
000:	 41 02 d0 18 83 07 08 00 01 0c 18 91 00 38 2a 18
010:	 00 00 00 80 04 06 00 00 00 81 00 00 02 83 06 07
020:	 22 00 0e 00 30 00 00 00 7c 4c 21 ff 00 00 00 00
030:	 18 47 00 00 00 00 00 00 00 00 00 00 0f 0f 00 80
040:	 0f 0f 00 80 0f 0f 00 00 0f 0f 00 80 81 00 00 00
050:	 81 00 00 00 04 00 00 00 04 00 00 00 37 02 00 00
060:	 00 00 00 00 00 00 00 00 01 80 c2 00 00 01 00 00
070:	 ff ff 00 00 50 7a 00 80 60 7a 00 00 00 00 00 00
080:	 02 80 04 04 00 23 00 00 ee 05 00 00 00 00 00 00
090:	 02 00 f7 01 00 00 00 00 fa f0 03 a5 40 08 01 00
0a0:	 08 10 60 00 04 18 0c 08 00 00 00 00 00 00 00 00
0b0:	 00 00 00 00 00 00 00 00 f9 8a 1f 71 08 00 00 00
0c0:	 0c 00 04 02 0d 00 60 00 a0 01 00 00 00 00 00 00
0d0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0e0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0f0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
100:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
110:	 00 00 00 00 02 00 00 00 aa 08 00 00 02 00 00 00
120:	 a9 08 00 00 00 00 00 00 48 00 00 00 7a 32 00 00
130:	 95 00 00 00 bb 00 00 00 85 02 00 00 d6 22 07 00
140:	 6d 59 07 00 3b 00 00 00 00 00 00 00 d1 8a 01 00
150:	 ca 2f 65 2a 00 00 00 00 dd f1 37 01 00 00 00 00
160:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
170:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
180:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
190:	 7b 59 07 00 24 9c 01 00 0a 00 00 00 65 64 01 00
1a0:	 c0 00 00 00 a8 00 00 00 bc 01 00 00 3e 23 00 00
1b0:	 00 00 00 00 06 00 00 00 f6 0b 00 00 9d 31 02 00
1c0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1d0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1e0:	 00 00 00 00 02 00 00 02 02 00 00 02 02 00 00 02
1f0:	 02 00 00 02 fe ff 07 00 fe ff 07 00 fe ff 07 00
200:	 fe ff 07 00 00 90 05 ad 00 90 03 b6 00 a0 0c b3
210:	 00 20 1b ad 04 00 00 00 04 00 00 00 04 00 00 00
220:	 04 00 00 00 00 10 00 00 00 10 00 00 00 10 00 00
230:	 00 10 00 00 59 00 00 00 91 00 00 00 8b 00 00 00
240:	 dc 00 00 00 57 00 00 00 8f 00 00 00 89 00 00 00
250:	 da 00 00 00 10 08 01 02 10 08 01 02 10 08 01 02
260:	 10 08 01 02 d0 03 00 00 d0 03 00 00 d0 03 00 00
270:	 d0 03 00 00 31 00 00 00 2d 00 00 00 31 00 00 00
280:	 31 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
290:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2a0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2b0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2c0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 30 48 c3
2d0:	 01 00 5e 00 00 00 00 00 00 00 00 00 00 00 00 00
2e0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2f0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
300:	 00 00 00 00 00 00 00 00 00 00 00 00 7d c2 00 80
310:	 00 01 00 80 00 00 00 80 00 00 00 80 00 00 00 80
320:	 00 00 00 80 00 00 00 80 00 00 00 80 00 00 00 80
330:	 00 00 00 80 00 00 00 80 00 00 00 80 00 00 00 80
340:	 00 00 00 80 00 00 00 80 00 00 00 80 00 f0 9d 9c
350:	 00 d0 df 9c 00 f0 c0 9c 00 c0 cf 9c 04 00 00 00
360:	 04 00 00 00 04 00 00 00 04 00 00 00 00 10 00 00
370:	 00 10 00 00 00 10 00 00 00 10 00 00 cb 00 00 00
380:	 40 00 00 00 1b 00 00 00 b6 00 00 00 cb 00 00 00
390:	 40 00 00 00 1b 00 00 00 b6 00 00 00 00 00 00 02
3a0:	 00 00 00 02 00 00 00 02 00 00 00 02 00 00 00 00
3b0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
3c0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 22 00 00
3d0:	 00 22 00 00 00 22 00 00 00 22 00 00 00 00 00 00
3e0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
3f0:	 00 00 00 00 00 00 00 00 00 00 00 00 00 30 48 c3
400:	 7d c2 00 02 b3 aa 06 03 08 00 45 00 00 34 37 9e
410:	 40 00 40 06 ed 0c 0a 00 01 06 0a 00 01 14 b5 23
420:	 0e 30 dc 6d b2 ad cd c0 a6 23 80 10 00 5c 18 8f
430:	 00 00 01 01 08 0a ff ff 85 31 ff ff fc 33 42 00
440:	 06 08 00 00 42 00 06 08 00 00 00 00 4a 00 06 08
450:	 00 00 00 00 65 64 5f 61 72 65 61 29 29 20 3f 20
460:	 21 21 28 6d 6d 2d 3e 67 65 74 5f 75 6e 6d 61 70
470:	 70 65 64 5f 61 72 65 61 20 3d 3d 20 01 00 00 00
480:	 0b 00 00 00 0f 00 00 00 0f 00 00 00 03 00 00 00
490:	 0f 00 00 00 0e 00 00 00 09 00 00 00 0c 00 00 00
4a0:	 02 00 00 00 0e 00 00 00 0f 00 00 00 05 00 00 00
4b0:	 0f 00 00 00 07 00 00 00 03 00 00 00 09 00 00 00
4c0:	 07 00 00 00 06 00 00 00 03 00 00 00 0c 00 00 00
4d0:	 01 00 00 00 07 00 00 00 0b 00 00 00 09 00 00 00
4e0:	 05 00 00 00 05 00 00 00 0d 00 00 00 07 00 00 00
4f0:	 0a 00 00 00 0f 00 00 00 0f 00 00 00 04 00 00 00
500:	 05 00 00 00 0e 00 00 00 0f 00 00 00 02 00 00 00
510:	 0c 00 00 00 0c 00 00 00 0a 00 00 00 04 00 00 00
520:	 0b 00 00 00 07 00 00 00 03 00 00 00 0d 00 00 00
530:	 07 00 00 00 0f 00 00 00 01 00 00 00 0f 00 00 00
540:	 07 00 00 00 05 00 00 00 0f 00 00 00 0d 00 00 00
550:	 0b 00 00 00 0a 00 00 00 02 00 00 00 07 00 00 00
560:	 07 00 00 00 0b 00 00 00 07 00 00 00 00 00 00 00
570:	 06 00 00 00 06 00 00 00 0b 00 00 00 0f 00 00 00
580:	 06 00 00 00 0f 00 00 00 01 00 00 00 0f 00 00 00
590:	 02 00 00 00 0e 00 00 00 07 00 00 00 0c 00 00 00
5a0:	 06 00 00 00 0f 00 00 00 0f 00 00 00 03 00 00 00
5b0:	 05 00 00 00 06 00 00 00 0d 00 00 00 0e 00 00 00
5c0:	 0b 00 00 00 0b 00 00 00 07 00 00 00 09 00 00 00
5d0:	 09 00 00 00 0f 00 00 00 06 00 00 00 0d 00 00 00
5e0:	 07 00 00 00 0f 00 00 00 0f 00 00 00 0c 00 00 00
5f0:	 07 00 00 00 02 00 00 00 0f 00 00 00 07 00 00 00
600:	 06 00 00 00 07 00 00 00 06 00 00 00 0c 00 00 00
610:	 02 00 00 00 07 00 00 00 03 00 00 00 0f 00 00 00
620:	 02 00 00 00 05 00 00 00 0f 00 00 00 0c 00 00 00
630:	 0d 00 00 00 0c 00 00 00 0f 00 00 00 08 00 00 00
640:	 0d 00 00 00 0f 00 00 00 0f 00 00 00 0d 00 00 00
650:	 07 00 00 00 0b 00 00 00 07 00 00 00 06 00 00 00
660:	 0d 00 00 00 0f 00 00 00 0f 00 00 00 0f 00 00 00
670:	 03 00 00 00 0f 00 00 00 0f 00 00 00 c3 77 ba 0d
680:	 f6 17 87 f5 cb 15 93 b5 e0 27 56 cc 4d 3b ca e1
690:	 bb 32 ef a2 fc 3b ff ff 5f fd bf fe e7 6a eb 5e
6a0:	 ff 29 0e 13 bd ed 7b dd da b8 84 91 39 f7 1c 7e
6b0:	 7f ae 57 ed f2 f7 7b ad fb fe ee b3 c7 2b 85 b4
6c0:	 de 65 f7 b7 df de 6b fd fb c6 57 e2 59 71 5a f6
6d0:	 39 e0 fe ee d9 37 ec ff fa fe e3 6c e4 13 59 ff
6e0:	 f2 8f 46 ef 4f 7f e0 d7 77 7c ec f6 e5 7d ff df
6f0:	 b9 ce 4a b9 e9 77 3b 2f de dd df df e5 49 28 6f
700:	 ea 2f 17 f5 7d ff cd 4e ce ff f6 f5 39 d3 82 e5
710:	 db ef 7e 21 e1 57 fe d7 c3 f5 cf 9f 3d f1 7e 47
720:	 cf ff 65 f0 c7 35 ab ef f3 fe 9d d5 e1 06 dc ae
730:	 df f5 5f ab 6f b9 dc ff fc 67 bf ac f9 c4 dc f4
740:	 98 fe 5e 08 ff 1b f7 df d6 1c ef e7 4b 7d a3 65
750:	 7a 62 67 a6 e1 43 31 ef 6a 89 66 ef 58 af 75 f7
760:	 f8 ee c7 a7 ed f7 e3 fd da ed fe cb 8b fb fa fe
770:	 ed 74 46 df b4 87 3b d7 f1 fd bf 42 c3 b1 b4 3f
780:	 78 b0 4e ec df 8b bb 77 7f ef d7 f1 ca c7 bb db
790:	 6a 3f 38 d0 df 7f ec b1 d4 e6 84 ff c8 95 38 8b
7a0:	 5c e0 55 e6 af 5d f8 df 78 2f df fb fd 9a 19 f6
7b0:	 d5 fc ae eb b7 ff 09 fe de 75 16 c9 7a 5e 87 d4
7c0:	 f8 fb bf b4 bf b6 f9 7d f6 fd cf 8b ec 9d 7a 36
7d0:	 9b 7c 57 2b 9d f6 0f ff 70 ff fc c7 65 ed 55 47
7e0:	 6f dd 8c ab f7 7e af ff 7a 7f fe 5f bb fe bc 7e
7f0:	 b9 2d 6d 6c f3 e7 6f 9f 6f 73 6e a5 ec 03 68 bc
800:	 d7 1b 5b a9 91 33 ea e5 e5 54 fb ef 68 f3 5d a7
810:	 7d 9c cb ea df f3 d2 ff da 7d 79 7c ec f5 e3 f5
820:	 6a ee 42 42 aa a0 fb be de 3c ff a7 ad 41 f9 fb
830:	 ed 2f 5d ce 59 f7 fb dd ff fd 7f 8d ed 08 da 27
840:	 db 39 ee d2 df 9f 0f bd db b7 eb bf 67 41 5c a4
850:	 9a 7d ff ec 6f f6 3f ab 8a fb ef 7b fa eb 31 5e
860:	 7e 77 6e bf df c6 e9 ef eb 3f f5 ad d3 57 dc bc
870:	 f1 65 cb 69 58 47 cf dd fa ac d7 28 00 00 00 00
880:	 00 00 00 00 00 00 00 00 00 00 00 00 28 17 00 00
890:	 34 17 00 00 34 17 00 00 00 00 00 00


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="boot.log"
Content-Transfer-Encoding: quoted-printable

Linux version 2.6.29-rc2 (mingo@aldebaran) (gcc version 4.3.2 20081007 (Red=
 Hat 4.3.2-6) (GCC) ) #41 SMP Wed Jan 21 18:52:12 CET 2009
Command line: root=3D/dev/sda1 earlyprintk=3Dserial,ttyS0,115200 console=3D=
ttyS0,115200 console=3Dtty debug initcall_debug apic=3Dverbose sysrq_always=
_enabled 5 ignore_loglevel panic=3D1
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000bf3d5000 (usable)
 BIOS-e820: 00000000bf3d5000 - 00000000bf3f7000 (ACPI NVS)
 BIOS-e820: 00000000bf3f7000 - 00000000bf450000 (reserved)
 BIOS-e820: 00000000bf450000 - 00000000bf451000 (ACPI NVS)
 BIOS-e820: 00000000bf451000 - 00000000bf453000 (reserved)
 BIOS-e820: 00000000bf453000 - 00000000bf45c000 (ACPI data)
 BIOS-e820: 00000000bf45c000 - 00000000bf466000 (ACPI NVS)
 BIOS-e820: 00000000bf466000 - 00000000bf483000 (reserved)
 BIOS-e820: 00000000bf483000 - 00000000bf686000 (ACPI NVS)
 BIOS-e820: 00000000bf686000 - 00000000bf800000 (usable)
 BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
 BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 00000004c0000000 (usable)
console [earlyser0] enabled
debug: ignoring loglevel setting.
DMI 2.4 present.
AMI BIOS detected: BIOS may corrupt low RAM, working it around.
last_pfn =3D 0x4c0000 max_arch_pfn =3D 0x100000000
last_pfn =3D 0xbf800 max_arch_pfn =3D 0x100000000
init_memory_mapping: 0000000000000000-00000000bf800000
 0000000000 - 00bf800000 page 2M
kernel direct mapping tables up to bf800000 @ 10000-14000
last_map_addr: bf800000 end: bf800000
init_memory_mapping: 0000000100000000-00000004c0000000
 0100000000 - 04c0000000 page 2M
kernel direct mapping tables up to 4c0000000 @ 12000-26000
last_map_addr: 4c0000000 end: 4c0000000
RAMDISK: 37d13000 - 37fef41b
ACPI: RSDP 000F03C0, 0024 (r2 ALASKA)
ACPI: XSDT BF45AE18, 004C (r1 ALASKA    A M I  6222004 MSFT    10013)
ACPI Warning (tbutils-0242): Incorrect checksum in table [XSDT] - E1, shoul=
d be F6 [20081204]
ACPI: FACP BF459D98, 00F4 (r4 ALASKA    A M I  6222004 MSFT    10013)
ACPI Warning (tbfadt-0328): 32/64 FACS address mismatch in FADT - two FACS =
tables! [20081204]
ACPI Warning (tbfadt-0530): 32/64X FACS address mismatch in FADT - two FACS=
 tables! BF463E40/00000000BF463D40 [20081204]
FADT: X_PM1a_EVT_BLK.bit_width (16) does not match PM1_EVT_LEN (4)
ACPI: DSDT BF453018, 5550 (r1 ALASKA    A M I        1 INTL 20051117)
ACPI: FACS BF463D40, 0040
ACPI: APIC BF450A98, 00E4 (r2 ALASKA    A M I  6222004 MSFT    10013)
ACPI: MCFG BF464D98, 003C (r1 A M I  OEMMCFG   6222004 MSFT       97)
ACPI: HPET BF464D18, 0038 (r1 A M I  ICH7HPET  6222004 AMI.        3)
ACPI: SPCR BF464C98, 0050 (r1 A M I    APTIO=04  6222004 AMI.        3)
ACPI: Local APIC address 0xfee00000
Setting APIC routing to cluster x2apic.
No NUMA configuration found
Faking a node at 0000000000000000-00000004c0000000
Bootmem setup node 0 0000000000000000-00000004c0000000
  NODE_DATA [0000000000021000 - 0000000000026fff]
  bootmap [0000000000100000 -  0000000000197fff] pages 98
(7 early reservations) =3D=3D> bootmem [0000000000 - 04c0000000]
  #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> [0000000000 - 00000=
01000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE =3D=3D> [0000006000 - 00000=
08000]
  #2 [0000200000 - 0000b089f0]    TEXT DATA BSS =3D=3D> [0000200000 - 0000b=
089f0]
  #3 [0037d13000 - 0037fef41b]          RAMDISK =3D=3D> [0037d13000 - 0037f=
ef41b]
  #4 [000009fc00 - 0000100000]    BIOS reserved =3D=3D> [000009fc00 - 00001=
00000]
  #5 [0000010000 - 0000012000]          PGTABLE =3D=3D> [0000010000 - 00000=
12000]
  #6 [0000012000 - 0000021000]          PGTABLE =3D=3D> [0000012000 - 00000=
21000]
Scan SMP from ffff880000000000 for 1024 bytes.
Scan SMP from ffff88000009fc00 for 1024 bytes.
Scan SMP from ffff8800000f0000 for 65536 bytes.
Scan SMP from ffff88000009fc00 for 1024 bytes.
 [ffffe20000000000-ffffe200107fffff] PMD -> [ffff880028200000-ffff880037bff=
fff] on node 0
 [ffffe20010800000-ffffe200109fffff] PMD -> [ffff880038000000-ffff8800381ff=
fff] on node 0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x004c0000
Movable zone start PFN for each node
early_node_map[4] active PFN ranges
    0: 0x00000010 -> 0x0000009f
    0: 0x00000100 -> 0x000bf3d5
    0: 0x000bf686 -> 0x000bf800
    0: 0x00100000 -> 0x004c0000
On node 0 totalpages: 4715742
  DMA zone: 56 pages used for memmap
  DMA zone: 2428 pages reserved
  DMA zone: 1499 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 765319 pages, LIFO batch:31
  Normal zone: 53760 pages used for memmap
  Normal zone: 3878400 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
Setting APIC routing to cluster x2apic.
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x04] enabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] enabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x06] enabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] enabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x10] enabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x11] enabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x12] enabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x13] enabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x14] enabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x15] enabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x16] enabled)
ACPI: LAPIC (acpi_id[0x10] lapic_id[0x17] enabled)
ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 0, version 0, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x05] address[0xfbd01000] gsi_base[24])
IOAPIC[1]: apic_id 5, version 0, address 0xfbd01000, GSI 24-47
ACPI: IOAPIC (id[0x07] address[0xfbd00000] gsi_base[48])
IOAPIC[2]: apic_id 7, version 0, address 0xfbd00000, GSI 48-71
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a301 base: 0xfed00000
SMP: Allowing 16 CPUs, 0 hotplug CPUs
mapped APIC to ffffffffff5fc000 (fee00000)
mapped IOAPIC to ffffffffff5fb000 (fec00000)
mapped IOAPIC to ffffffffff5fa000 (fbd01000)
mapped IOAPIC to ffffffffff5f9000 (fbd00000)
Allocating PCI resources starting at c0000000 (gap: bf800000:3f51c000)
NR_CPUS:255 nr_cpumask_bits:255 nr_cpu_ids:16 nr_node_ids:1
PERCPU: Allocating 61440 bytes of per cpu data
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4645218
Policy zone: Normal
Kernel command line: root=3D/dev/sda1 earlyprintk=3Dserial,ttyS0,115200 con=
sole=3DttyS0,115200 console=3Dtty debug initcall_debug apic=3Dverbose sysrq=
_always_enabled 5 ignore_loglevel panic=3D1
debug: sysrq always enabled.
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
Extended CMOS year: 2000
TSC: PIT calibration matches PMTIMER. 1 loops
Detected 2400.080 MHz processor.
Console: colour VGA+ 80x25
console handover: boot [earlyser0] -> real [tty0]
console [ttyS0] enabled
Checking aperture...
No AGP bridge found
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing 64MB software IO TLB between ffff880020000000 - ffff880024000000
software IO TLB at phys 0x20000000 - 0x24000000
Memory: 18525372k/19922944k available (3616k kernel code, 1059976k absent, =
337596k reserved, 2358k data, 496k init)
hpet clockevent registered
HPET: 4 timers in total, 0 timers will be used for per-cpu timer
Calibrating delay loop (skipped), value calculated using timer frequency.. =
4800.16 BogoMIPS (lpj=3D9600320)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Dentry cache hash table entries: 4194304 (order: 13, 33554432 bytes)
Inode-cache hash table entries: 2097152 (order: 12, 16777216 bytes)
Mount-cache hash table entries: 256
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 0/0x0 -> Node 0
CPU0: Thermal monitoring enabled (TM1)
using mwait in idle threads.
ACPI: Core revision 20081204
ftrace: converting mcount calls to 0f 1f 44 00 00
ftrace: allocating 15799 entries in 125 pages
dmar_table_init() failed with -19:
Not enabling x2apic,Intr-remapping
Setting APIC routing to physical flat
enabled ExtINT on CPU#0
ENABLING IO-APIC IRQs
init IO_APIC IRQs
 0-0 (apicid-pin) not connected
IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Active:0)
IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 Active:0)
 0-16 0-17 0-18 0-19 0-20 0-21 0-22 0-23 5-0 5-1 5-2 5-3 5-4 5-5 5-6 5-7 5-=
8 5-9 5-10 5-11 5-12 5-13 5-14 5-15 5-16 5-17 5-18 5-19 5-20 5-21 5-22 5-23=
 7-0 7-1 7-2 7-3 7-4 7-5 7-6 7-7 7-8 7-9 7-10 7-11 7-12 7-13 7-14 7-15 7-16=
 7-17 7-18 7-19 7-20 7-21 7-22 7-23 (apicid-pin) not connected
=2E.TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
CPU0: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
Using local APIC timer interrupts.
calibrating APIC timer ...
=2E.. lapic delta =3D 833386
=2E.. PM timer delta =3D 357965
=2E.. PM timer result ok
=2E.... delta 833386
=2E.... mult: 35791419
=2E.... calibration result: 533367
=2E.... CPU clock speed is 2400.0620 MHz.
=2E.... host bus clock speed is 133.1367 MHz.
calling  migration_init+0x0/0x5b @ 1
initcall migration_init+0x0/0x5b returned 1 after 0 usecs
initcall migration_init+0x0/0x5b returned with error code 1=20
calling  spawn_ksoftirqd+0x0/0x58 @ 1
initcall spawn_ksoftirqd+0x0/0x58 returned 0 after 0 usecs
calling  init_call_single_data+0x0/0x67 @ 1
initcall init_call_single_data+0x0/0x67 returned 0 after 0 usecs
calling  relay_init+0x0/0x14 @ 1
initcall relay_init+0x0/0x14 returned 0 after 0 usecs
calling  tracer_alloc_buffers+0x0/0x21b @ 1
initcall tracer_alloc_buffers+0x0/0x21b returned 0 after 7812 usecs
Booting processor 1 APIC 0x1 ip 0x6000
Initializing CPU#1
masked ExtINT on CPU#1
Calibrating delay using timer specific routine.. 4800.12 BogoMIPS (lpj=3D96=
00256)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 1/0x1 -> Node 0
CPU1: Thermal monitoring enabled (TM1)
CPU1: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Booting processor 2 APIC 0x2 ip 0x6000
Initializing CPU#2
masked ExtINT on CPU#2
Calibrating delay using timer specific routine.. 4800.13 BogoMIPS (lpj=3D96=
00270)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 2/0x2 -> Node 0
CPU2: Thermal monitoring enabled (TM1)
CPU2: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#2]: passed.
Booting processor 3 APIC 0x3 ip 0x6000
Initializing CPU#3
masked ExtINT on CPU#3
Calibrating delay using timer specific routine.. 4800.13 BogoMIPS (lpj=3D96=
00275)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 3/0x3 -> Node 0
CPU3: Thermal monitoring enabled (TM1)
CPU3: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#3]: passed.
Booting processor 4 APIC 0x4 ip 0x6000
Initializing CPU#4
masked ExtINT on CPU#4
Calibrating delay using timer specific routine.. 4800.13 BogoMIPS (lpj=3D96=
00276)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 4/0x4 -> Node 0
CPU4: Thermal monitoring enabled (TM1)
CPU4: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#4]: passed.
Booting processor 5 APIC 0x5 ip 0x6000
Initializing CPU#5
masked ExtINT on CPU#5
Calibrating delay using timer specific routine.. 4800.14 BogoMIPS (lpj=3D96=
00280)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 5/0x5 -> Node 0
CPU5: Thermal monitoring enabled (TM1)
CPU5: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#5]: passed.
Booting processor 6 APIC 0x6 ip 0x6000
Initializing CPU#6
masked ExtINT on CPU#6
Calibrating delay using timer specific routine.. 4800.14 BogoMIPS (lpj=3D96=
00290)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 3
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 6/0x6 -> Node 0
CPU6: Thermal monitoring enabled (TM1)
CPU6: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#6]: passed.
Booting processor 7 APIC 0x7 ip 0x6000
Initializing CPU#7
masked ExtINT on CPU#7
Calibrating delay using timer specific routine.. 4800.13 BogoMIPS (lpj=3D96=
00275)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 3
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 7/0x7 -> Node 0
CPU7: Thermal monitoring enabled (TM1)
CPU7: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#7]: passed.
Booting processor 8 APIC 0x10 ip 0x6000
Initializing CPU#8
masked ExtINT on CPU#8
Calibrating delay using timer specific routine.. 4800.19 BogoMIPS (lpj=3D96=
00396)
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 8/0x10 -> Node 0
CPU8: Thermal monitoring enabled (TM1)
CPU8: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#8]: passed.
Booting processor 9 APIC 0x11 ip 0x6000
Initializing CPU#9
masked ExtINT on CPU#9
Calibrating delay using timer specific routine.. 4800.20 BogoMIPS (lpj=3D96=
00400)
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 9/0x11 -> Node 0
CPU9: Thermal monitoring enabled (TM1)
CPU9: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#9]: passed.
Booting processor 10 APIC 0x12 ip 0x6000
Initializing CPU#10
masked ExtINT on CPU#10
Calibrating delay using timer specific routine.. 4800.18 BogoMIPS (lpj=3D96=
00376)
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 10/0x12 -> Node 0
CPU10: Thermal monitoring enabled (TM1)
CPU10: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#10]: passed.
Booting processor 11 APIC 0x13 ip 0x6000
Initializing CPU#11
masked ExtINT on CPU#11
Calibrating delay using timer specific routine.. 4800.20 BogoMIPS (lpj=3D96=
00408)
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 11/0x13 -> Node 0
CPU11: Thermal monitoring enabled (TM1)
CPU11: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#11]: passed.
Booting processor 12 APIC 0x14 ip 0x6000
Initializing CPU#12
masked ExtINT on CPU#12
Calibrating delay using timer specific routine.. 4800.20 BogoMIPS (lpj=3D96=
00412)
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 12/0x14 -> Node 0
CPU12: Thermal monitoring enabled (TM1)
CPU12: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#12]: passed.
Booting processor 13 APIC 0x15 ip 0x6000
Initializing CPU#13
masked ExtINT on CPU#13
Calibrating delay using timer specific routine.. 4800.20 BogoMIPS (lpj=3D96=
00409)
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 13/0x15 -> Node 0
CPU13: Thermal monitoring enabled (TM1)
CPU13: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#13]: passed.
Booting processor 14 APIC 0x16 ip 0x6000
Initializing CPU#14
masked ExtINT on CPU#14
Calibrating delay using timer specific routine.. 4800.22 BogoMIPS (lpj=3D96=
00454)
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 3
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 14/0x16 -> Node 0
CPU14: Thermal monitoring enabled (TM1)
CPU14: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#14]: passed.
Booting processor 15 APIC 0x17 ip 0x6000
Initializing CPU#15
masked ExtINT on CPU#15
Calibrating delay using timer specific routine.. 4800.20 BogoMIPS (lpj=3D96=
00414)
CPU: Physical Processor ID: 1
CPU: Processor Core ID: 3
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
[ds] using core 2 configuration
CPU 15/0x17 -> Node 0
CPU15: Thermal monitoring enabled (TM1)
CPU15: Genuine Intel(R) CPU           @ 0000 @ 2.40GHz stepping 02
checking TSC synchronization [CPU#0 -> CPU#15]: passed.
Brought up 16 CPUs
Total of 16 processors activated (76802.75 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0-1 level SIBLING
  groups: 0 1
  domain 1: span 0-7 level MC
   groups: 0-1 2-3 4-5 6-7
   domain 2: span 0-15 level CPU
    groups: 0-7 8-15
CPU1 attaching sched-domain:
 domain 0: span 0-1 level SIBLING
  groups: 1 0
  domain 1: span 0-7 level MC
   groups: 0-1 2-3 4-5 6-7
   domain 2: span 0-15 level CPU
    groups: 0-7 8-15
CPU2 attaching sched-domain:
 domain 0: span 2-3 level SIBLING
  groups: 2 3
  domain 1: span 0-7 level MC
   groups: 2-3 4-5 6-7 0-1
   domain 2: span 0-15 level CPU
    groups: 0-7 8-15
CPU3 attaching sched-domain:
 domain 0: span 2-3 level SIBLING
  groups: 3 2
  domain 1: span 0-7 level MC
   groups: 2-3 4-5 6-7 0-1
   domain 2: span 0-15 level CPU
    groups: 0-7 8-15
CPU4 attaching sched-domain:
 domain 0: span 4-5 level SIBLING
  groups: 4 5
  domain 1: span 0-7 level MC
   groups: 4-5 6-7 0-1 2-3
   domain 2: span 0-15 level CPU
    groups: 0-7 8-15
CPU5 attaching sched-domain:
 domain 0: span 4-5 level SIBLING
  groups: 5 4
  domain 1: span 0-7 level MC
   groups: 4-5 6-7 0-1 2-3
   domain 2: span 0-15 level CPU
    groups: 0-7 8-15
CPU6 attaching sched-domain:
 domain 0: span 6-7 level SIBLING
  groups: 6 7
  domain 1: span 0-7 level MC
   groups: 6-7 0-1 2-3 4-5
   domain 2: span 0-15 level CPU
    groups: 0-7 8-15
CPU7 attaching sched-domain:
 domain 0: span 6-7 level SIBLING
  groups: 7 6
  domain 1: span 0-7 level MC
   groups: 6-7 0-1 2-3 4-5
   domain 2: span 0-15 level CPU
    groups: 0-7 8-15
CPU8 attaching sched-domain:
 domain 0: span 8-9 level SIBLING
  groups: 8 9
  domain 1: span 8-15 level MC
   groups: 8-9 10-11 12-13 14-15
   domain 2: span 0-15 level CPU
    groups: 8-15 0-7
CPU9 attaching sched-domain:
 domain 0: span 8-9 level SIBLING
  groups: 9 8
  domain 1: span 8-15 level MC
   groups: 8-9 10-11 12-13 14-15
   domain 2: span 0-15 level CPU
    groups: 8-15 0-7
CPU10 attaching sched-domain:
 domain 0: span 10-11 level SIBLING
  groups: 10 11
  domain 1: span 8-15 level MC
   groups: 10-11 12-13 14-15 8-9
   domain 2: span 0-15 level CPU
    groups: 8-15 0-7
CPU11 attaching sched-domain:
 domain 0: span 10-11 level SIBLING
  groups: 11 10
  domain 1: span 8-15 level MC
   groups: 10-11 12-13 14-15 8-9
   domain 2: span 0-15 level CPU
    groups: 8-15 0-7
CPU12 attaching sched-domain:
 domain 0: span 12-13 level SIBLING
  groups: 12 13
  domain 1: span 8-15 level MC
   groups: 12-13 14-15 8-9 10-11
   domain 2: span 0-15 level CPU
    groups: 8-15 0-7
CPU13 attaching sched-domain:
 domain 0: span 12-13 level SIBLING
  groups: 13 12
  domain 1: span 8-15 level MC
   groups: 12-13 14-15 8-9 10-11
   domain 2: span 0-15 level CPU
    groups: 8-15 0-7
CPU14 attaching sched-domain:
 domain 0: span 14-15 level SIBLING
  groups: 14 15
  domain 1: span 8-15 level MC
   groups: 14-15 8-9 10-11 12-13
   domain 2: span 0-15 level CPU
    groups: 8-15 0-7
CPU15 attaching sched-domain:
 domain 0: span 14-15 level SIBLING
  groups: 15 14
  domain 1: span 8-15 level MC
   groups: 14-15 8-9 10-11 12-13
   domain 2: span 0-15 level CPU
    groups: 8-15 0-7
calling  init_cpufreq_transition_notifier_list+0x0/0x1b @ 1
initcall init_cpufreq_transition_notifier_list+0x0/0x1b returned 0 after 0 =
usecs
calling  net_ns_init+0x0/0x12e @ 1
net_namespace: 1744 bytes
initcall net_ns_init+0x0/0x12e returned 0 after 3906 usecs
calling  cpufreq_tsc+0x0/0x28 @ 1
initcall cpufreq_tsc+0x0/0x28 returned 0 after 0 usecs
calling  init_smp_flush+0x0/0x5d @ 1
initcall init_smp_flush+0x0/0x5d returned 0 after 0 usecs
calling  alloc_frozen_cpus+0x0/0xd @ 1
initcall alloc_frozen_cpus+0x0/0xd returned 0 after 0 usecs
calling  sysctl_init+0x0/0x32 @ 1
initcall sysctl_init+0x0/0x32 returned 0 after 0 usecs
calling  ksysfs_init+0x0/0xbb @ 1
initcall ksysfs_init+0x0/0xbb returned 0 after 0 usecs
calling  async_init+0x0/0x38 @ 1
initcall async_init+0x0/0x38 returned 0 after 0 usecs
calling  init_jiffies_clocksource+0x0/0x12 @ 1
initcall init_jiffies_clocksource+0x0/0x12 returned 0 after 0 usecs
calling  pm_init+0x0/0x34 @ 1
initcall pm_init+0x0/0x34 returned 0 after 0 usecs
calling  init_irq_default_affinity+0x0/0x2b @ 1
initcall init_irq_default_affinity+0x0/0x2b returned 0 after 0 usecs
calling  filelock_init+0x0/0x2e @ 1
initcall filelock_init+0x0/0x2e returned 0 after 0 usecs
calling  init_misc_binfmt+0x0/0x3f @ 1
initcall init_misc_binfmt+0x0/0x3f returned 0 after 0 usecs
calling  init_script_binfmt+0x0/0x12 @ 1
initcall init_script_binfmt+0x0/0x12 returned 0 after 0 usecs
calling  init_elf_binfmt+0x0/0x12 @ 1
initcall init_elf_binfmt+0x0/0x12 returned 0 after 0 usecs
calling  init_compat_elf_binfmt+0x0/0x12 @ 1
initcall init_compat_elf_binfmt+0x0/0x12 returned 0 after 0 usecs
calling  debugfs_init+0x0/0x51 @ 1
initcall debugfs_init+0x0/0x51 returned 0 after 0 usecs
calling  securityfs_init+0x0/0x51 @ 1
initcall securityfs_init+0x0/0x51 returned 0 after 0 usecs
calling  random32_init+0x0/0xe1 @ 1
initcall random32_init+0x0/0xe1 returned 0 after 0 usecs
calling  cpufreq_core_init+0x0/0x8d @ 1
initcall cpufreq_core_init+0x0/0x8d returned 0 after 0 usecs
calling  sock_init+0x0/0x5e @ 1
initcall sock_init+0x0/0x5e returned 0 after 0 usecs
calling  netpoll_init+0x0/0x31 @ 1
initcall netpoll_init+0x0/0x31 returned 0 after 0 usecs
calling  netlink_proto_init+0x0/0x14b @ 1
NET: Registered protocol family 16
initcall netlink_proto_init+0x0/0x14b returned 0 after 0 usecs
calling  bdi_class_init+0x0/0x41 @ 1
initcall bdi_class_init+0x0/0x41 returned 0 after 0 usecs
calling  kobject_uevent_init+0x0/0x47 @ 1
initcall kobject_uevent_init+0x0/0x47 returned 0 after 0 usecs
calling  pcibus_class_init+0x0/0x19 @ 1
initcall pcibus_class_init+0x0/0x19 returned 0 after 0 usecs
calling  pci_driver_init+0x0/0x12 @ 1
initcall pci_driver_init+0x0/0x12 returned 0 after 0 usecs
calling  backlight_class_init+0x0/0x5d @ 1
initcall backlight_class_init+0x0/0x5d returned 0 after 0 usecs
calling  tty_class_init+0x0/0x31 @ 1
initcall tty_class_init+0x0/0x31 returned 0 after 0 usecs
calling  vtconsole_class_init+0x0/0xc3 @ 1
initcall vtconsole_class_init+0x0/0xc3 returned 0 after 3906 usecs
calling  register_node_type+0x0/0x7e @ 1
initcall register_node_type+0x0/0x7e returned 0 after 0 usecs
calling  amd_postcore_init+0x0/0x854 @ 1
initcall amd_postcore_init+0x0/0x854 returned 0 after 0 usecs
calling  arch_kdebugfs_init+0x0/0x24 @ 1
initcall arch_kdebugfs_init+0x0/0x24 returned 0 after 0 usecs
calling  mtrr_if_init+0x0/0x79 @ 1
initcall mtrr_if_init+0x0/0x79 returned 0 after 0 usecs
calling  ffh_cstate_init+0x0/0x31 @ 1
initcall ffh_cstate_init+0x0/0x31 returned 0 after 0 usecs
calling  acpi_pci_init+0x0/0x57 @ 1
ACPI: bus type pci registered
initcall acpi_pci_init+0x0/0x57 returned 0 after 3906 usecs
calling  init_acpi_device_notify+0x0/0x4b @ 1
initcall init_acpi_device_notify+0x0/0x4b returned 0 after 0 usecs
calling  dmi_id_init+0x0/0x2f1 @ 1
initcall dmi_id_init+0x0/0x2f1 returned 0 after 0 usecs
calling  pci_arch_init+0x0/0x57 @ 1
PCI: MCFG configuration 0: base c0000000 segment 0 buses 0 - 255
PCI: Not using MMCONFIG.
PCI: Using configuration type 1 for base access
initcall pci_arch_init+0x0/0x57 returned 0 after 11718 usecs
calling  topology_init+0x0/0x90 @ 1
initcall topology_init+0x0/0x90 returned 0 after 0 usecs
calling  mtrr_init_finialize+0x0/0x3d @ 1
initcall mtrr_init_finialize+0x0/0x3d returned 0 after 0 usecs
calling  param_sysfs_init+0x0/0x1d0 @ 1
initcall param_sysfs_init+0x0/0x1d0 returned 0 after 3906 usecs
calling  pm_sysrq_init+0x0/0x1e @ 1
initcall pm_sysrq_init+0x0/0x1e returned 0 after 0 usecs
calling  readahead_init+0x0/0x38 @ 1
initcall readahead_init+0x0/0x38 returned 0 after 0 usecs
calling  init_bio+0x0/0xcb @ 1
bio: create slab <bio-0> at 0
initcall init_bio+0x0/0xcb returned 0 after 0 usecs
calling  cryptomgr_init+0x0/0x31 @ 1
initcall cryptomgr_init+0x0/0x31 returned 0 after 0 usecs
calling  blk_settings_init+0x0/0x2a @ 1
initcall blk_settings_init+0x0/0x2a returned 0 after 0 usecs
calling  blk_ioc_init+0x0/0x2a @ 1
initcall blk_ioc_init+0x0/0x2a returned 0 after 0 usecs
calling  blk_softirq_init+0x0/0x78 @ 1
initcall blk_softirq_init+0x0/0x78 returned 0 after 0 usecs
calling  genhd_device_init+0x0/0x66 @ 1
initcall genhd_device_init+0x0/0x66 returned 0 after 0 usecs
calling  pci_slot_init+0x0/0x4c @ 1
initcall pci_slot_init+0x0/0x4c returned 0 after 0 usecs
calling  fbmem_init+0x0/0x91 @ 1
initcall fbmem_init+0x0/0x91 returned 0 after 0 usecs
calling  acpi_init+0x0/0x239 @ 1
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S3 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: MCFG configuration 0: base c0000000 segment 0 buses 0 - 255
PCI: BIOS Bug: MCFG area at c0000000 is not reserved in ACPI motherboard re=
sources
PCI: Not using MMCONFIG.
initcall acpi_init+0x0/0x239 returned 0 after 46875 usecs
calling  acpi_scan_init+0x0/0x109 @ 1
ACPI: BIOS _OSI(Linux) query ignored
initcall acpi_scan_init+0x0/0x109 returned 0 after 15625 usecs
calling  acpi_ec_init+0x0/0x61 @ 1
initcall acpi_ec_init+0x0/0x61 returned 0 after 0 usecs
calling  dock_init+0x0/0x8d @ 1
ACPI: No dock devices found.
initcall dock_init+0x0/0x8d returned 0 after 3906 usecs
calling  acpi_pci_root_init+0x0/0x28 @ 1
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PME# disabled
pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
pci 0000:00:03.0: PME# disabled
pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
pci 0000:00:05.0: PME# disabled
pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
pci 0000:00:07.0: PME# disabled
pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
pci 0000:00:09.0: PME# disabled
pci 0000:00:13.0: reg 10 32bit mmio: [0xfbf21000-0xfbf21fff]
pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
pci 0000:00:13.0: PME# disabled
pci 0000:00:16.0: reg 10 64bit mmio: [0xfbf1c000-0xfbf1ffff]
pci 0000:00:16.1: reg 10 64bit mmio: [0xfbf18000-0xfbf1bfff]
pci 0000:00:16.2: reg 10 64bit mmio: [0xfbf14000-0xfbf17fff]
pci 0000:00:16.3: reg 10 64bit mmio: [0xfbf10000-0xfbf13fff]
pci 0000:00:16.4: reg 10 64bit mmio: [0xfbf0c000-0xfbf0ffff]
pci 0000:00:16.5: reg 10 64bit mmio: [0xfbf08000-0xfbf0bfff]
pci 0000:00:16.6: reg 10 64bit mmio: [0xfbf04000-0xfbf07fff]
pci 0000:00:16.7: reg 10 64bit mmio: [0xfbf00000-0xfbf03fff]
pci 0000:00:1a.0: reg 20 io port: [0xf0c0-0xf0df]
pci 0000:00:1a.1: reg 20 io port: [0xf0a0-0xf0bf]
pci 0000:00:1a.2: reg 20 io port: [0xf080-0xf09f]
pci 0000:00:1a.7: reg 10 32bit mmio: [0xfbf22400-0xfbf227ff]
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: PME# disabled
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.4: PME# disabled
pci 0000:00:1d.0: reg 20 io port: [0xf060-0xf07f]
pci 0000:00:1d.1: reg 20 io port: [0xf040-0xf05f]
pci 0000:00:1d.2: reg 20 io port: [0xf020-0xf03f]
pci 0000:00:1d.7: reg 10 32bit mmio: [0xfbf22000-0xfbf223ff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 0500-053f claimed by ICH6 GPIO
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0600 (mask 00ff)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 0290 (mask 001f)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 4 PIO at 0ca0 (mask 000f)
pci 0000:00:1f.2: reg 10 io port: [0xf190-0xf197]
pci 0000:00:1f.2: reg 14 io port: [0xf180-0xf183]
pci 0000:00:1f.2: reg 18 io port: [0xf170-0xf177]
pci 0000:00:1f.2: reg 1c io port: [0xf160-0xf163]
pci 0000:00:1f.2: reg 20 io port: [0xf150-0xf15f]
pci 0000:00:1f.2: reg 24 io port: [0xf140-0xf14f]
pci 0000:00:1f.3: reg 10 64bit mmio: [0xfbf22800-0xfbf228ff]
pci 0000:00:1f.3: reg 20 io port: [0xf000-0xf01f]
pci 0000:00:1f.5: reg 10 io port: [0xf130-0xf137]
pci 0000:00:1f.5: reg 14 io port: [0xf120-0xf123]
pci 0000:00:1f.5: reg 18 io port: [0xf110-0xf117]
pci 0000:00:1f.5: reg 1c io port: [0xf100-0xf103]
pci 0000:00:1f.5: reg 20 io port: [0xf0f0-0xf0ff]
pci 0000:00:1f.5: reg 24 io port: [0xf0e0-0xf0ef]
pci 0000:00:1f.6: reg 10 64bit mmio: [0xfbf20000-0xfbf20fff]
pci 0000:01:00.0: reg 10 32bit mmio: [0xfbea0000-0xfbebffff]
pci 0000:01:00.0: reg 14 32bit mmio: [0xfbe80000-0xfbe9ffff]
pci 0000:01:00.0: reg 18 io port: [0xe020-0xe03f]
pci 0000:01:00.0: reg 1c 32bit mmio: [0xfbec4000-0xfbec7fff]
pci 0000:01:00.0: reg 30 32bit mmio: [0xfbe60000-0xfbe7ffff]
pci 0000:01:00.0: PME# supported from D0 D3hot D3cold
pci 0000:01:00.0: PME# disabled
pci 0000:01:00.1: reg 10 32bit mmio: [0xfbe40000-0xfbe5ffff]
pci 0000:01:00.1: reg 14 32bit mmio: [0xfbe20000-0xfbe3ffff]
pci 0000:01:00.1: reg 18 io port: [0xe000-0xe01f]
pci 0000:01:00.1: reg 1c 32bit mmio: [0xfbec0000-0xfbec3fff]
pci 0000:01:00.1: reg 30 32bit mmio: [0xfbe00000-0xfbe1ffff]
pci 0000:01:00.1: PME# supported from D0 D3hot D3cold
pci 0000:01:00.1: PME# disabled
pci 0000:00:01.0: bridge io port: [0xe000-0xefff]
pci 0000:00:01.0: bridge 32bit mmio: [0xfbe00000-0xfbefffff]
pci 0000:05:00.0: PXH quirk detected; SHPC device MSI disabled
pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
pci 0000:05:00.0: PME# disabled
pci 0000:05:00.1: reg 10 32bit mmio: [0xfbd01000-0xfbd01fff]
pci 0000:05:00.2: PXH quirk detected; SHPC device MSI disabled
pci 0000:05:00.2: PME# supported from D0 D3hot D3cold
pci 0000:05:00.2: PME# disabled
pci 0000:05:00.3: reg 10 32bit mmio: [0xfbd00000-0xfbd00fff]
pci 0000:00:09.0: bridge 32bit mmio: [0xfbd00000-0xfbdfffff]
pci 0000:09:00.0: reg 10 io port: [0xd040-0xd047]
pci 0000:09:00.0: reg 14 io port: [0xd030-0xd033]
pci 0000:09:00.0: reg 18 io port: [0xd020-0xd027]
pci 0000:09:00.0: reg 1c io port: [0xd010-0xd013]
pci 0000:09:00.0: reg 20 io port: [0xd000-0xd00f]
pci 0000:09:00.0: reg 30 32bit mmio: [0xfbc00000-0xfbc0ffff]
pci 0000:00:1c.4: bridge io port: [0xd000-0xdfff]
pci 0000:00:1c.4: bridge 32bit mmio: [0xfbc00000-0xfbcfffff]
pci 0000:0a:01.0: reg 10 32bit mmio: [0xf0000000-0xf7ffffff]
pci 0000:0a:01.0: reg 14 io port: [0xc000-0xc0ff]
pci 0000:0a:01.0: reg 18 32bit mmio: [0xfbb20000-0xfbb2ffff]
pci 0000:0a:01.0: reg 30 32bit mmio: [0xfbb00000-0xfbb1ffff]
pci 0000:0a:01.0: supports D1 D2
pci 0000:00:1e.0: transparent bridge
pci 0000:00:1e.0: bridge io port: [0xc000-0xcfff]
pci 0000:00:1e.0: bridge 32bit mmio: [0xfbb00000-0xfbbfffff]
pci 0000:00:1e.0: bridge 64bit mmio pref: [0xf0000000-0xf7ffffff]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE7._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE9._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE9.PXHB._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE9.PXHA._PRT]
initcall acpi_pci_root_init+0x0/0x28 returned 0 after 425781 usecs
calling  acpi_pci_link_init+0x0/0x63 @ 1
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs *3 4 5 6 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 14 15) *0
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 *5 6 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 11 12 14 15) *0
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *10 11 12 14 15)
initcall acpi_pci_link_init+0x0/0x63 returned 0 after 58593 usecs
calling  acpi_power_init+0x0/0x77 @ 1
initcall acpi_power_init+0x0/0x77 returned 0 after 0 usecs
calling  acpi_system_init+0x0/0x276 @ 1
initcall acpi_system_init+0x0/0x276 returned 0 after 0 usecs
calling  pnp_init+0x0/0x12 @ 1
initcall pnp_init+0x0/0x12 returned 0 after 0 usecs
calling  misc_init+0x0/0x9f @ 1
initcall misc_init+0x0/0x9f returned 0 after 0 usecs
calling  cn_init+0x0/0xf3 @ 1
initcall cn_init+0x0/0xf3 returned 0 after 0 usecs
calling  phy_init+0x0/0x31 @ 1
initcall phy_init+0x0/0x31 returned 0 after 0 usecs
calling  init_scsi+0x0/0x91 @ 1
SCSI subsystem initialized
initcall init_scsi+0x0/0x91 returned 0 after 3906 usecs
calling  ata_init+0x0/0x388 @ 1
libata version 3.00 loaded.
initcall ata_init+0x0/0x388 returned 0 after 3906 usecs
calling  init_pcmcia_cs+0x0/0x2f @ 1
initcall init_pcmcia_cs+0x0/0x2f returned 0 after 0 usecs
calling  usb_init+0x0/0x15a @ 1
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
initcall usb_init+0x0/0x15a returned 0 after 11718 usecs
calling  serio_init+0x0/0x89 @ 1
initcall serio_init+0x0/0x89 returned 0 after 0 usecs
calling  input_init+0x0/0x10e @ 1
initcall input_init+0x0/0x10e returned 0 after 0 usecs
calling  power_supply_class_init+0x0/0x38 @ 1
initcall power_supply_class_init+0x0/0x38 returned 0 after 0 usecs
calling  hwmon_init+0x0/0x42 @ 1
initcall hwmon_init+0x0/0x42 returned 0 after 0 usecs
calling  thermal_init+0x0/0x40 @ 1
initcall thermal_init+0x0/0x40 returned 0 after 0 usecs
calling  md_init+0x0/0xd0 @ 1
initcall md_init+0x0/0xd0 returned 0 after 0 usecs
calling  leds_init+0x0/0x40 @ 1
initcall leds_init+0x0/0x40 returned 0 after 0 usecs
calling  pci_subsys_init+0x0/0x121 @ 1
PCI: Using ACPI for IRQ routing
initcall pci_subsys_init+0x0/0x121 returned 0 after 3906 usecs
calling  proto_init+0x0/0x12 @ 1
initcall proto_init+0x0/0x12 returned 0 after 0 usecs
calling  net_dev_init+0x0/0x179 @ 1
initcall net_dev_init+0x0/0x179 returned 0 after 3906 usecs
calling  neigh_init+0x0/0x71 @ 1
initcall neigh_init+0x0/0x71 returned 0 after 0 usecs
calling  fib_rules_init+0x0/0xa6 @ 1
initcall fib_rules_init+0x0/0xa6 returned 0 after 0 usecs
calling  pktsched_init+0x0/0xc4 @ 1
initcall pktsched_init+0x0/0xc4 returned 0 after 0 usecs
calling  tc_filter_init+0x0/0x4c @ 1
initcall tc_filter_init+0x0/0x4c returned 0 after 0 usecs
calling  tc_action_init+0x0/0x4c @ 1
initcall tc_action_init+0x0/0x4c returned 0 after 0 usecs
calling  genl_init+0x0/0xd8 @ 1
initcall genl_init+0x0/0xd8 returned 0 after 15625 usecs
calling  cipso_v4_init+0x0/0x64 @ 1
initcall cipso_v4_init+0x0/0x64 returned 0 after 0 usecs
calling  wireless_nlevent_init+0x0/0x31 @ 1
initcall wireless_nlevent_init+0x0/0x31 returned 0 after 0 usecs
calling  netlbl_init+0x0/0x81 @ 1
NetLabel: Initializing
NetLabel:  domain hash size =3D 128
NetLabel:  protocols =3D UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
initcall netlbl_init+0x0/0x81 returned 0 after 11718 usecs
calling  sysctl_init+0x0/0x49 @ 1
initcall sysctl_init+0x0/0x49 returned 0 after 0 usecs
calling  pci_iommu_init+0x0/0x1c @ 1
initcall pci_iommu_init+0x0/0x1c returned 0 after 0 usecs
calling  print_all_ICs+0x0/0x524 @ 1

printing PIC contents
=2E.. PIC  IMR: ffff
=2E.. PIC  IRR: 0c28
=2E.. PIC  ISR: 0000
=2E.. PIC ELCR: 0c28

printing local APIC contents on CPU#0/0:
=2E.. APIC ID:      00000000 (0)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 01000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 000000fc
=2E.. APIC ICR2: 17000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00000400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00006453
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#1/1:
=2E.. APIC ID:      01000000 (1)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 02000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 000011ac
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#2/2:
=2E.. APIC ID:      02000000 (2)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 04000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 0000560f
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#3/3:
=2E.. APIC ID:      03000000 (3)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 08000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00000c86
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#4/4:
=2E.. APIC ID:      04000000 (4)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 10000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00005d68
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#5/5:
=2E.. APIC ID:      05000000 (5)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 20000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00001591
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#6/6:
=2E.. APIC ID:      06000000 (6)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 40000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 0000545f
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#7/7:
=2E.. APIC ID:      07000000 (7)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 80000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00002786
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#8/16:
=2E.. APIC ID:      10000000 (10)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 00000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00001683
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#9/17:
=2E.. APIC ID:      11000000 (11)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 00000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00000f32
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#10/18:
=2E.. APIC ID:      12000000 (12)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 00000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00001099
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#11/19:
=2E.. APIC ID:      13000000 (13)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 00000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 000053e8
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#12/20:
=2E.. APIC ID:      14000000 (14)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 00000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 0000523d
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#13/21:
=2E.. APIC ID:      15000000 (15)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 00000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00003f81
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#14/22:
=2E.. APIC ID:      16000000 (16)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 00000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00001512
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#15/23:
=2E.. APIC ID:      17000000 (17)
=2E.. APIC VERSION: 00060015
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 00000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 00000000
=2E.. APIC ICR2: 00000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 00008237
=2E.. APIC TMCCT: 00000f75
=2E.. APIC TDCR: 00000003

number of MP IRQ sources: 15.
number of IO-APIC #0 registers: 24.
number of IO-APIC #5 registers: 24.
number of IO-APIC #7 registers: 24.
testing the IO APIC.......................

IO APIC #0......
=2E... register #00: 00000000
=2E......    : physical APIC id: 00
=2E......    : Delivery Type: 0
=2E......    : LTS          : 0
=2E... register #01: 00170020
=2E......     : max redirection entries: 0017
=2E......     : PRQ implemented: 0
=2E......     : IO APIC version: 0020
=2E... IRQ redirection table:
 NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:  =20
 00 000 1    0    0   0   0    0    0    00
 01 000 0    0    0   0   0    0    0    31
 02 000 0    0    0   0   0    0    0    30
 03 000 0    0    0   0   0    0    0    33
 04 000 0    0    0   0   0    0    0    34
 05 000 0    0    0   0   0    0    0    35
 06 000 0    0    0   0   0    0    0    36
 07 000 0    0    0   0   0    0    0    37
 08 000 0    0    0   0   0    0    0    38
 09 000 0    1    0   0   0    0    0    39
 0a 000 0    0    0   0   0    0    0    3A
 0b 000 0    0    0   0   0    0    0    3B
 0c 000 0    0    0   0   0    0    0    3C
 0d 000 0    0    0   0   0    0    0    3D
 0e 000 0    0    0   0   0    0    0    3E
 0f 000 0    0    0   0   0    0    0    3F
 10 000 1    0    0   0   0    0    0    00
 11 000 1    0    0   0   0    0    0    00
 12 000 1    0    0   0   0    0    0    00
 13 000 1    0    0   0   0    0    0    00
 14 000 1    0    0   0   0    0    0    00
 15 000 1    0    0   0   0    0    0    00
 16 000 1    0    0   0   0    0    0    00
 17 000 1    0    0   0   0    0    0    00

IO APIC #5......
=2E... register #00: 05000000
=2E......    : physical APIC id: 05
=2E......    : Delivery Type: 0
=2E......    : LTS          : 0
=2E... register #01: 00178020
=2E......     : max redirection entries: 0017
=2E......     : PRQ implemented: 1
=2E......     : IO APIC version: 0020
=2E... register #02: 05000000
=2E......     : arbitration: 05
=2E... register #03: 00000001
=2E......     : Boot DT    : 1
=2E... IRQ redirection table:
 NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:  =20
 00 000 1    0    0   0   0    0    0    00
 01 000 1    0    0   0   0    0    0    00
 02 000 1    0    0   0   0    0    0    00
 03 000 1    0    0   0   0    0    0    00
 04 000 1    0    0   0   0    0    0    00
 05 000 1    0    0   0   0    0    0    00
 06 000 1    0    0   0   0    0    0    00
 07 000 1    0    0   0   0    0    0    00
 08 000 1    0    0   0   0    0    0    00
 09 000 1    0    0   0   0    0    0    00
 0a 000 1    0    0   0   0    0    0    00
 0b 000 1    0    0   0   0    0    0    00
 0c 000 1    0    0   0   0    0    0    00
 0d 000 1    0    0   0   0    0    0    00
 0e 000 1    0    0   0   0    0    0    00
 0f 000 1    0    0   0   0    0    0    00
 10 000 1    0    0   0   0    0    0    00
 11 000 1    0    0   0   0    0    0    00
 12 000 1    0    0   0   0    0    0    00
 13 000 1    0    0   0   0    0    0    00
 14 000 1    0    0   0   0    0    0    00
 15 000 1    0    0   0   0    0    0    00
 16 000 1    0    0   0   0    0    0    00
 17 000 1    0    0   0   0    0    0    00

IO APIC #7......
=2E... register #00: 07000000
=2E......    : physical APIC id: 07
=2E......    : Delivery Type: 0
=2E......    : LTS          : 0
=2E... register #01: 00178020
=2E......     : max redirection entries: 0017
=2E......     : PRQ implemented: 1
=2E......     : IO APIC version: 0020
=2E... register #02: 07000000
=2E......     : arbitration: 07
=2E... register #03: 00000001
=2E......     : Boot DT    : 1
=2E... IRQ redirection table:
 NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:  =20
 00 000 1    0    0   0   0    0    0    00
 01 000 1    0    0   0   0    0    0    00
 02 000 1    0    0   0   0    0    0    00
 03 000 1    0    0   0   0    0    0    00
 04 000 1    0    0   0   0    0    0    00
 05 000 1    0    0   0   0    0    0    00
 06 000 1    0    0   0   0    0    0    00
 07 000 1    0    0   0   0    0    0    00
 08 000 1    0    0   0   0    0    0    00
 09 000 1    0    0   0   0    0    0    00
 0a 000 1    0    0   0   0    0    0    00
 0b 000 1    0    0   0   0    0    0    00
 0c 000 1    0    0   0   0    0    0    00
 0d 000 1    0    0   0   0    0    0    00
 0e 000 1    0    0   0   0    0    0    00
 0f 000 1    0    0   0   0    0    0    00
 10 000 1    0    0   0   0    0    0    00
 11 000 1    0    0   0   0    0    0    00
 12 000 1    0    0   0   0    0    0    00
 13 000 1    0    0   0   0    0    0    00
 14 000 1    0    0   0   0    0    0    00
 15 000 1    0    0   0   0    0    0    00
 16 000 1    0    0   0   0    0    0    00
 17 000 1    0    0   0   0    0    0    00
IRQ to pin mappings:
IRQ0 -> 0:2
IRQ1 -> 0:1
IRQ3 -> 0:3
IRQ4 -> 0:4
IRQ5 -> 0:5
IRQ6 -> 0:6
IRQ7 -> 0:7
IRQ8 -> 0:8
IRQ9 -> 0:9
IRQ10 -> 0:10
IRQ11 -> 0:11
IRQ12 -> 0:12
IRQ13 -> 0:13
IRQ14 -> 0:14
IRQ15 -> 0:15
=2E................................... done.
initcall print_all_ICs+0x0/0x524 returned 0 after 4101562 usecs
calling  hpet_late_init+0x0/0x92 @ 1
initcall hpet_late_init+0x0/0x92 returned 0 after 31250 usecs
calling  clocksource_done_booting+0x0/0x12 @ 1
initcall clocksource_done_booting+0x0/0x12 returned 0 after 0 usecs
calling  ftrace_init_debugfs+0x0/0x134 @ 1
initcall ftrace_init_debugfs+0x0/0x134 returned 0 after 31 usecs
calling  rb_init_debugfs+0x0/0x40 @ 1
initcall rb_init_debugfs+0x0/0x40 returned 0 after 19 usecs
calling  tracer_init_debugfs+0x0/0x2d0 @ 1
initcall tracer_init_debugfs+0x0/0x2d0 returned 0 after 38 usecs
calling  init_pipe_fs+0x0/0x4c @ 1
initcall init_pipe_fs+0x0/0x4c returned 0 after 21 usecs
calling  init_mnt_writers+0x0/0x62 @ 1
initcall init_mnt_writers+0x0/0x62 returned 0 after 17 usecs
calling  eventpoll_init+0x0/0xa2 @ 1
initcall eventpoll_init+0x0/0xa2 returned 0 after 50 usecs
calling  anon_inode_init+0x0/0x11f @ 1
initcall anon_inode_init+0x0/0x11f returned 0 after 20 usecs
calling  acpi_event_init+0x0/0x80 @ 1
initcall acpi_event_init+0x0/0x80 returned 0 after 15172 usecs
calling  pnpacpi_init+0x0/0x8c @ 1
pnp: PnP ACPI init
ACPI: bus type pnp registered
IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 Active:0)
pnp: PnP ACPI: found 14 devices
ACPI: ACPI bus type pnp unregistered
initcall pnpacpi_init+0x0/0x8c returned 0 after 53578 usecs
calling  pnp_system_init+0x0/0x12 @ 1
system 00:01: iomem range 0xfc000000-0xfcffffff has been reserved
system 00:01: iomem range 0xfd000000-0xfdffffff has been reserved
system 00:01: iomem range 0xfe000000-0xfebfffff has been reserved
system 00:02: ioport range 0x290-0x29f has been reserved
system 00:0a: ioport range 0x4d0-0x4d1 has been reserved
system 00:0c: ioport range 0x400-0x47f has been reserved
system 00:0c: ioport range 0x1180-0x119f has been reserved
system 00:0c: ioport range 0x500-0x53f has been reserved
system 00:0c: iomem range 0xfed1c000-0xfed1ffff has been reserved
system 00:0c: iomem range 0xfec00000-0xfecfffff has been reserved
system 00:0c: iomem range 0xfee00000-0xfee0ffff has been reserved
system 00:0c: iomem range 0xfed20000-0xfed3ffff has been reserved
system 00:0c: iomem range 0xfed40000-0xfed4ffff has been reserved
system 00:0c: iomem range 0xfed50000-0xfed8ffff has been reserved
system 00:0c: iomem range 0xffc00000-0xffffffff has been reserved
initcall pnp_system_init+0x0/0x12 returned 0 after 87089 usecs
calling  chr_dev_init+0x0/0xa1 @ 1
initcall chr_dev_init+0x0/0xa1 returned 0 after 439 usecs
calling  firmware_class_init+0x0/0x79 @ 1
initcall firmware_class_init+0x0/0x79 returned 0 after 61 usecs
calling  init_pcmcia_bus+0x0/0x74 @ 1
initcall init_pcmcia_bus+0x0/0x74 returned 0 after 71 usecs
calling  cpufreq_gov_performance_init+0x0/0x12 @ 1
initcall cpufreq_gov_performance_init+0x0/0x12 returned 0 after 16 usecs
calling  cpufreq_gov_userspace_init+0x0/0x12 @ 1
initcall cpufreq_gov_userspace_init+0x0/0x12 returned 0 after 15 usecs
calling  init_acpi_pm_clocksource+0x0/0xdd @ 1
initcall init_acpi_pm_clocksource+0x0/0xdd returned 0 after 4425 usecs
calling  pcibios_assign_resources+0x0/0x88 @ 1
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: 0xe000-0xefff
pci 0000:00:01.0:   MEM window: 0xfbe00000-0xfbefffff
pci 0000:00:01.0:   PREFETCH window: disabled
pci 0000:00:03.0: PCI bridge, secondary bus 0000:02
pci 0000:00:03.0:   IO window: disabled
pci 0000:00:03.0:   MEM window: disabled
pci 0000:00:03.0:   PREFETCH window: disabled
pci 0000:00:05.0: PCI bridge, secondary bus 0000:03
pci 0000:00:05.0:   IO window: disabled
pci 0000:00:05.0:   MEM window: disabled
pci 0000:00:05.0:   PREFETCH window: disabled
pci 0000:00:07.0: PCI bridge, secondary bus 0000:04
pci 0000:00:07.0:   IO window: disabled
pci 0000:00:07.0:   MEM window: disabled
pci 0000:00:07.0:   PREFETCH window: disabled
pci 0000:05:00.0: PCI bridge, secondary bus 0000:06
pci 0000:05:00.0:   IO window: disabled
pci 0000:05:00.0:   MEM window: disabled
pci 0000:05:00.0:   PREFETCH window: disabled
pci 0000:05:00.2: PCI bridge, secondary bus 0000:07
pci 0000:05:00.2:   IO window: disabled
pci 0000:05:00.2:   MEM window: disabled
pci 0000:05:00.2:   PREFETCH window: disabled
pci 0000:00:09.0: PCI bridge, secondary bus 0000:05
pci 0000:00:09.0:   IO window: disabled
pci 0000:00:09.0:   MEM window: 0xfbd00000-0xfbdfffff
pci 0000:00:09.0:   PREFETCH window: disabled
pci 0000:00:1c.0: PCI bridge, secondary bus 0000:08
pci 0000:00:1c.0:   IO window: disabled
pci 0000:00:1c.0:   MEM window: disabled
pci 0000:00:1c.0:   PREFETCH window: disabled
pci 0000:00:1c.4: PCI bridge, secondary bus 0000:09
pci 0000:00:1c.4:   IO window: 0xd000-0xdfff
pci 0000:00:1c.4:   MEM window: 0xfbc00000-0xfbcfffff
pci 0000:00:1c.4:   PREFETCH window: disabled
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:0a
pci 0000:00:1e.0:   IO window: 0xc000-0xcfff
pci 0000:00:1e.0:   MEM window: 0xfbb00000-0xfbbfffff
pci 0000:00:1e.0:   PREFETCH window: 0x000000f0000000-0x000000f7ffffff
IOAPIC[0]: Set routing entry (0-16 -> 0x49 -> IRQ 16 Mode:1 Active:1)
pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:01.0: setting latency timer to 64
pci 0000:00:03.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:03.0: setting latency timer to 64
pci 0000:00:05.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:05.0: setting latency timer to 64
pci 0000:00:07.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:07.0: setting latency timer to 64
pci 0000:00:09.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:09.0: setting latency timer to 64
pci 0000:05:00.0: setting latency timer to 64
pci 0000:05:00.2: setting latency timer to 64
IOAPIC[0]: Set routing entry (0-17 -> 0x51 -> IRQ 17 Mode:1 Active:1)
pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
pci 0000:00:1c.0: setting latency timer to 64
pci 0000:00:1c.4: PCI INT A -> GSI 17 (level, low) -> IRQ 17
pci 0000:00:1c.4: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
pci_bus 0000:01: resource 0 io:  [0xe000-0xefff]
pci_bus 0000:01: resource 1 mem: [0xfbe00000-0xfbefffff]
pci_bus 0000:01: resource 2 mem: [0x0-0x0]
pci_bus 0000:01: resource 3 mem: [0x0-0x0]
pci_bus 0000:02: resource 0 mem: [0x0-0x0]
pci_bus 0000:02: resource 1 mem: [0x0-0x0]
pci_bus 0000:02: resource 2 mem: [0x0-0x0]
pci_bus 0000:02: resource 3 mem: [0x0-0x0]
pci_bus 0000:03: resource 0 mem: [0x0-0x0]
pci_bus 0000:03: resource 1 mem: [0x0-0x0]
pci_bus 0000:03: resource 2 mem: [0x0-0x0]
pci_bus 0000:03: resource 3 mem: [0x0-0x0]
pci_bus 0000:04: resource 0 mem: [0x0-0x0]
pci_bus 0000:04: resource 1 mem: [0x0-0x0]
pci_bus 0000:04: resource 2 mem: [0x0-0x0]
pci_bus 0000:04: resource 3 mem: [0x0-0x0]
pci_bus 0000:05: resource 0 mem: [0x0-0x0]
pci_bus 0000:05: resource 1 mem: [0xfbd00000-0xfbdfffff]
pci_bus 0000:05: resource 2 mem: [0x0-0x0]
pci_bus 0000:05: resource 3 mem: [0x0-0x0]
pci_bus 0000:06: resource 0 mem: [0x0-0x0]
pci_bus 0000:06: resource 1 mem: [0x0-0x0]
pci_bus 0000:06: resource 2 mem: [0x0-0x0]
pci_bus 0000:06: resource 3 mem: [0x0-0x0]
pci_bus 0000:07: resource 0 mem: [0x0-0x0]
pci_bus 0000:07: resource 1 mem: [0x0-0x0]
pci_bus 0000:07: resource 2 mem: [0x0-0x0]
pci_bus 0000:07: resource 3 mem: [0x0-0x0]
pci_bus 0000:08: resource 0 mem: [0x0-0x0]
pci_bus 0000:08: resource 1 mem: [0x0-0x0]
pci_bus 0000:08: resource 2 mem: [0x0-0x0]
pci_bus 0000:08: resource 3 mem: [0x0-0x0]
pci_bus 0000:09: resource 0 io:  [0xd000-0xdfff]
pci_bus 0000:09: resource 1 mem: [0xfbc00000-0xfbcfffff]
pci_bus 0000:09: resource 2 mem: [0x0-0x0]
pci_bus 0000:09: resource 3 mem: [0x0-0x0]
pci_bus 0000:0a: resource 0 io:  [0xc000-0xcfff]
pci_bus 0000:0a: resource 1 mem: [0xfbb00000-0xfbbfffff]
pci_bus 0000:0a: resource 2 mem: [0xf0000000-0xf7ffffff]
pci_bus 0000:0a: resource 3 io:  [0x00-0xffff]
pci_bus 0000:0a: resource 4 mem: [0x000000-0xffffffffffffffff]
initcall pcibios_assign_resources+0x0/0x88 returned 0 after 479529 usecs
calling  sysctl_core_init+0x0/0x38 @ 1
initcall sysctl_core_init+0x0/0x38 returned 0 after 30 usecs
calling  inet_init+0x0/0x209 @ 1
NET: Registered protocol family 2
IP route cache hash table entries: 1048576 (order: 11, 8388608 bytes)
TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
initcall inet_init+0x0/0x209 returned 0 after 90163 usecs
calling  af_unix_init+0x0/0x55 @ 1
NET: Registered protocol family 1
initcall af_unix_init+0x0/0x55 returned 0 after 3366 usecs
calling  populate_rootfs+0x0/0xee @ 1
checking if image is initramfs... it is
Freeing initrd memory: 2929k freed
initcall populate_rootfs+0x0/0xee returned 0 after 189151 usecs
calling  calgary_fixup_tce_spaces+0x0/0xf9 @ 1
initcall calgary_fixup_tce_spaces+0x0/0xf9 returned -19 after 16 usecs
calling  i8259A_init_sysfs+0x0/0x22 @ 1
initcall i8259A_init_sysfs+0x0/0x22 returned 0 after 110 usecs
calling  vsyscall_init+0x0/0x6c @ 1
initcall vsyscall_init+0x0/0x6c returned 0 after 31 usecs
calling  sbf_init+0x0/0xef @ 1
initcall sbf_init+0x0/0xef returned 0 after 16 usecs
calling  i8237A_init_sysfs+0x0/0x22 @ 1
initcall i8237A_init_sysfs+0x0/0x22 returned 0 after 121 usecs
calling  add_rtc_cmos+0x0/0xc1 @ 1
initcall add_rtc_cmos+0x0/0xc1 returned 0 after 21 usecs
calling  cache_sysfs_init+0x0/0x67 @ 1
initcall cache_sysfs_init+0x0/0x67 returned 0 after 3819 usecs
calling  mce_init_device+0x0/0x81 @ 1
initcall mce_init_device+0x0/0x81 returned 0 after 822 usecs
calling  periodic_mcheck_init+0x0/0x3f @ 1
initcall periodic_mcheck_init+0x0/0x3f returned 0 after 17 usecs
calling  thermal_throttle_init_device+0x0/0x95 @ 1
initcall thermal_throttle_init_device+0x0/0x95 returned 0 after 38 usecs
calling  threshold_init_device+0x0/0x4d @ 1
initcall threshold_init_device+0x0/0x4d returned 0 after 19 usecs
calling  msr_init+0x0/0x136 @ 1
initcall msr_init+0x0/0x136 returned 0 after 759 usecs
calling  cpuid_init+0x0/0x136 @ 1
initcall cpuid_init+0x0/0x136 returned 0 after 853 usecs
calling  init_lapic_sysfs+0x0/0x2d @ 1
initcall init_lapic_sysfs+0x0/0x2d returned 0 after 100 usecs
calling  ioapic_init_sysfs+0x0/0xa7 @ 1
initcall ioapic_init_sysfs+0x0/0xa7 returned 0 after 186 usecs
calling  add_pcspkr+0x0/0x28 @ 1
initcall add_pcspkr+0x0/0x28 returned 0 after 68 usecs
calling  uv_ptc_init+0x0/0x4f @ 1
initcall uv_ptc_init+0x0/0x4f returned 0 after 16 usecs
calling  uv_bau_init+0x0/0x5c9 @ 1
initcall uv_bau_init+0x0/0x5c9 returned 0 after 16 usecs
calling  sgi_uv_sysfs_init+0x0/0x94 @ 1
initcall sgi_uv_sysfs_init+0x0/0x94 returned 0 after 19 usecs
calling  audit_classes_init+0x0/0xaf @ 1
initcall audit_classes_init+0x0/0xaf returned 0 after 21 usecs
calling  init_vdso_vars+0x0/0x220 @ 1
initcall init_vdso_vars+0x0/0x220 returned 0 after 23 usecs
calling  ia32_binfmt_init+0x0/0x14 @ 1
initcall ia32_binfmt_init+0x0/0x14 returned 0 after 19 usecs
calling  sysenter_setup+0x0/0x2d5 @ 1
initcall sysenter_setup+0x0/0x2d5 returned 0 after 18 usecs
calling  init_sched_debug_procfs+0x0/0x2c @ 1
initcall init_sched_debug_procfs+0x0/0x2c returned 0 after 19 usecs
calling  proc_schedstat_init+0x0/0x22 @ 1
initcall proc_schedstat_init+0x0/0x22 returned 0 after 17 usecs
calling  proc_execdomains_init+0x0/0x22 @ 1
initcall proc_execdomains_init+0x0/0x22 returned 0 after 17 usecs
calling  ioresources_init+0x0/0x3c @ 1
initcall ioresources_init+0x0/0x3c returned 0 after 17 usecs
calling  uid_cache_init+0x0/0x8d @ 1
initcall uid_cache_init+0x0/0x8d returned 0 after 34 usecs
calling  init_posix_timers+0x0/0xe4 @ 1
initcall init_posix_timers+0x0/0xe4 returned 0 after 33 usecs
calling  init_posix_cpu_timers+0x0/0xb0 @ 1
initcall init_posix_cpu_timers+0x0/0xb0 returned 0 after 15 usecs
calling  nsproxy_cache_init+0x0/0x2d @ 1
initcall nsproxy_cache_init+0x0/0x2d returned 0 after 32 usecs
calling  create_proc_profile+0x0/0x2d5 @ 1
initcall create_proc_profile+0x0/0x2d5 returned 0 after 16 usecs
calling  timekeeping_init_device+0x0/0x22 @ 1
initcall timekeeping_init_device+0x0/0x22 returned 0 after 103 usecs
calling  init_clocksource_sysfs+0x0/0x50 @ 1
initcall init_clocksource_sysfs+0x0/0x50 returned 0 after 97 usecs
calling  init_timer_list_procfs+0x0/0x2c @ 1
initcall init_timer_list_procfs+0x0/0x2c returned 0 after 17 usecs
calling  futex_init+0x0/0xab @ 1
initcall futex_init+0x0/0xab returned 0 after 21 usecs
calling  init_rttest+0x0/0x146 @ 1
Initializing RT-Tester: OK
initcall init_rttest+0x0/0x146 returned 0 after 3327 usecs
calling  proc_dma_init+0x0/0x22 @ 1
initcall proc_dma_init+0x0/0x22 returned 0 after 17 usecs
calling  proc_modules_init+0x0/0x22 @ 1
initcall proc_modules_init+0x0/0x22 returned 0 after 16 usecs
calling  percpu_modinit+0x0/0x79 @ 1
initcall percpu_modinit+0x0/0x79 returned 0 after 15 usecs
calling  kallsyms_init+0x0/0x25 @ 1
initcall kallsyms_init+0x0/0x25 returned 0 after 16 usecs
calling  crash_save_vmcoreinfo_init+0x0/0x468 @ 1
initcall crash_save_vmcoreinfo_init+0x0/0x468 returned 0 after 29 usecs
calling  crash_notes_memory_init+0x0/0x3f @ 1
initcall crash_notes_memory_init+0x0/0x3f returned 0 after 24 usecs
calling  audit_init+0x0/0x15a @ 1
audit: initializing netlink socket (disabled)
type=3D2000 audit(1232564012.475:1): initialized
initcall audit_init+0x0/0x15a returned 0 after 8816 usecs
calling  audit_tree_init+0x0/0x49 @ 1
initcall audit_tree_init+0x0/0x49 returned 0 after 16 usecs
calling  init_kprobes+0x0/0x155 @ 1
initcall init_kprobes+0x0/0x155 returned 0 after 3244 usecs
calling  utsname_sysctl_init+0x0/0x14 @ 1
initcall utsname_sysctl_init+0x0/0x14 returned 0 after 26 usecs
calling  init_markers+0x0/0x17 @ 1
initcall init_markers+0x0/0x17 returned 0 after 15 usecs
calling  init_tracepoints+0x0/0x17 @ 1
initcall init_tracepoints+0x0/0x17 returned 0 after 15 usecs
calling  init_sched_switch_trace+0x0/0x12 @ 1
initcall init_sched_switch_trace+0x0/0x12 returned 0 after 16 usecs
calling  init_stack_trace+0x0/0x12 @ 1
initcall init_stack_trace+0x0/0x12 returned 0 after 16 usecs
calling  init_function_trace+0x0/0x12 @ 1
initcall init_function_trace+0x0/0x12 returned 0 after 15 usecs
calling  init_irqsoff_tracer+0x0/0x14 @ 1
initcall init_irqsoff_tracer+0x0/0x14 returned 0 after 15 usecs
calling  init_wakeup_tracer+0x0/0x12 @ 1
initcall init_wakeup_tracer+0x0/0x12 returned 0 after 15 usecs
calling  stack_trace_init+0x0/0x8d @ 1
initcall stack_trace_init+0x0/0x8d returned 0 after 21 usecs
calling  init_graph_trace+0x0/0x12 @ 1
initcall init_graph_trace+0x0/0x12 returned 0 after 16 usecs
calling  init_power_trace+0x0/0x12 @ 1
initcall init_power_trace+0x0/0x12 returned 0 after 15 usecs
calling  init_per_zone_pages_min+0x0/0x88 @ 1
initcall init_per_zone_pages_min+0x0/0x88 returned 0 after 928 usecs
calling  pdflush_init+0x0/0x12 @ 1
initcall pdflush_init+0x0/0x12 returned 0 after 74 usecs
calling  kswapd_init+0x0/0x71 @ 1
initcall kswapd_init+0x0/0x71 returned 0 after 52 usecs
calling  init_tmpfs+0x0/0xda @ 1
initcall init_tmpfs+0x0/0xda returned 0 after 55 usecs
calling  setup_vmstat+0x0/0xc3 @ 1
initcall setup_vmstat+0x0/0xc3 returned 0 after 29 usecs
calling  mm_sysfs_init+0x0/0x29 @ 1
initcall mm_sysfs_init+0x0/0x29 returned 0 after 19 usecs
calling  proc_vmalloc_init+0x0/0x25 @ 1
initcall proc_vmalloc_init+0x0/0x25 returned 0 after 17 usecs
calling  procswaps_init+0x0/0x22 @ 1
initcall procswaps_init+0x0/0x22 returned 0 after 16 usecs
calling  hugetlb_init+0x0/0x370 @ 1
HugeTLB registered 2 MB page size, pre-allocated 0 pages
initcall hugetlb_init+0x0/0x370 returned 0 after 5298 usecs
calling  slab_proc_init+0x0/0x25 @ 1
initcall slab_proc_init+0x0/0x25 returned 0 after 16 usecs
calling  cpucache_init+0x0/0x3e @ 1
initcall cpucache_init+0x0/0x3e returned 0 after 22 usecs
calling  fasync_init+0x0/0x2a @ 1
initcall fasync_init+0x0/0x2a returned 0 after 35 usecs
calling  proc_filesystems_init+0x0/0x22 @ 1
initcall proc_filesystems_init+0x0/0x22 returned 0 after 17 usecs
calling  dnotify_init+0x0/0x2a @ 1
initcall dnotify_init+0x0/0x2a returned 0 after 31 usecs
calling  inotify_setup+0x0/0x12 @ 1
initcall inotify_setup+0x0/0x12 returned 0 after 15 usecs
calling  inotify_user_setup+0x0/0xb8 @ 1
initcall inotify_user_setup+0x0/0xb8 returned 0 after 54 usecs
calling  aio_setup+0x0/0x71 @ 1
initcall aio_setup+0x0/0x71 returned 0 after 420 usecs
calling  proc_locks_init+0x0/0x22 @ 1
initcall proc_locks_init+0x0/0x22 returned 0 after 18 usecs
calling  init_sys32_ioctl+0x0/0x85 @ 1
initcall init_sys32_ioctl+0x0/0x85 returned 0 after 26 usecs
calling  init_mbcache+0x0/0x14 @ 1
initcall init_mbcache+0x0/0x14 returned 0 after 16 usecs
calling  dquot_init+0x0/0xe5 @ 1
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
initcall dquot_init+0x0/0xe5 returned 0 after 8336 usecs
calling  init_v2_quota_format+0x0/0x12 @ 1
initcall init_v2_quota_format+0x0/0x12 returned 0 after 16 usecs
calling  proc_cmdline_init+0x0/0x22 @ 1
initcall proc_cmdline_init+0x0/0x22 returned 0 after 17 usecs
calling  proc_cpuinfo_init+0x0/0x22 @ 1
initcall proc_cpuinfo_init+0x0/0x22 returned 0 after 17 usecs
calling  proc_devices_init+0x0/0x22 @ 1
initcall proc_devices_init+0x0/0x22 returned 0 after 16 usecs
calling  proc_interrupts_init+0x0/0x22 @ 1
initcall proc_interrupts_init+0x0/0x22 returned 0 after 17 usecs
calling  proc_loadavg_init+0x0/0x22 @ 1
initcall proc_loadavg_init+0x0/0x22 returned 0 after 16 usecs
calling  proc_meminfo_init+0x0/0x22 @ 1
initcall proc_meminfo_init+0x0/0x22 returned 0 after 16 usecs
calling  proc_stat_init+0x0/0x22 @ 1
initcall proc_stat_init+0x0/0x22 returned 0 after 16 usecs
calling  proc_uptime_init+0x0/0x2d @ 1
initcall proc_uptime_init+0x0/0x2d returned 0 after 16 usecs
calling  proc_version_init+0x0/0x22 @ 1
initcall proc_version_init+0x0/0x22 returned 0 after 17 usecs
calling  proc_kcore_init+0x0/0x49 @ 1
initcall proc_kcore_init+0x0/0x49 returned 0 after 17 usecs
calling  proc_kmsg_init+0x0/0x25 @ 1
initcall proc_kmsg_init+0x0/0x25 returned 0 after 17 usecs
calling  proc_page_init+0x0/0x42 @ 1
initcall proc_page_init+0x0/0x42 returned 0 after 17 usecs
calling  init_devpts_fs+0x0/0x3f @ 1
initcall init_devpts_fs+0x0/0x3f returned 0 after 26 usecs
calling  init_ext3_fs+0x0/0x71 @ 1
initcall init_ext3_fs+0x0/0x71 returned 0 after 50 usecs
calling  journal_init+0x0/0x93 @ 1
initcall journal_init+0x0/0x93 returned 0 after 83 usecs
calling  init_ext2_fs+0x0/0x72 @ 1
initcall init_ext2_fs+0x0/0x72 returned 0 after 50 usecs
calling  init_ramfs_fs+0x0/0x12 @ 1
initcall init_ramfs_fs+0x0/0x12 returned 0 after 16 usecs
calling  init_hugetlbfs_fs+0x0/0x98 @ 1
initcall init_hugetlbfs_fs+0x0/0x98 returned 0 after 48 usecs
calling  init_iso9660_fs+0x0/0x71 @ 1
initcall init_iso9660_fs+0x0/0x71 returned 0 after 40 usecs
calling  init_nls_cp437+0x0/0x12 @ 1
initcall init_nls_cp437+0x0/0x12 returned 0 after 16 usecs
calling  init_nls_ascii+0x0/0x12 @ 1
initcall init_nls_ascii+0x0/0x12 returned 0 after 16 usecs
calling  ipc_init+0x0/0x23 @ 1
msgmni has been set to 32768
initcall ipc_init+0x0/0x23 returned 0 after 2940 usecs
calling  ipc_sysctl_init+0x0/0x14 @ 1
initcall ipc_sysctl_init+0x0/0x14 returned 0 after 35 usecs
calling  init_mqueue_fs+0x0/0xc6 @ 1
initcall init_mqueue_fs+0x0/0xc6 returned 0 after 49 usecs
calling  key_proc_init+0x0/0x59 @ 1
initcall key_proc_init+0x0/0x59 returned 0 after 18 usecs
calling  selinux_nf_ip_init+0x0/0x60 @ 1
SELinux:  Registering netfilter hooks
initcall selinux_nf_ip_init+0x0/0x60 returned 0 after 3683 usecs
calling  init_sel_fs+0x0/0x68 @ 1
initcall init_sel_fs+0x0/0x68 returned 0 after 83 usecs
calling  selnl_init+0x0/0x4d @ 1
initcall selnl_init+0x0/0x4d returned 0 after 18 usecs
calling  sel_netif_init+0x0/0x66 @ 1
initcall sel_netif_init+0x0/0x66 returned 0 after 17 usecs
calling  sel_netnode_init+0x0/0x73 @ 1
initcall sel_netnode_init+0x0/0x73 returned 0 after 16 usecs
calling  sel_netport_init+0x0/0x73 @ 1
initcall sel_netport_init+0x0/0x73 returned 0 after 16 usecs
calling  aurule_init+0x0/0x37 @ 1
initcall aurule_init+0x0/0x37 returned 0 after 15 usecs
calling  crypto_algapi_init+0x0/0xd @ 1
initcall crypto_algapi_init+0x0/0xd returned 0 after 17 usecs
calling  chainiv_module_init+0x0/0x12 @ 1
initcall chainiv_module_init+0x0/0x12 returned 0 after 16 usecs
calling  eseqiv_module_init+0x0/0x12 @ 1
initcall eseqiv_module_init+0x0/0x12 returned 0 after 15 usecs
calling  hmac_module_init+0x0/0x12 @ 1
initcall hmac_module_init+0x0/0x12 returned 0 after 15 usecs
calling  md5_mod_init+0x0/0x12 @ 1
initcall md5_mod_init+0x0/0x12 returned 0 after 79 usecs
calling  sha1_generic_mod_init+0x0/0x12 @ 1
initcall sha1_generic_mod_init+0x0/0x12 returned 0 after 64 usecs
calling  crc32c_mod_init+0x0/0x12 @ 1
initcall crc32c_mod_init+0x0/0x12 returned 0 after 73 usecs
calling  krng_mod_init+0x0/0x12 @ 1
alg: No test for stdrng (krng)
initcall krng_mod_init+0x0/0x12 returned 0 after 2943 usecs
calling  proc_genhd_init+0x0/0x3c @ 1
initcall proc_genhd_init+0x0/0x3c returned 0 after 19 usecs
calling  noop_init+0x0/0x14 @ 1
io scheduler noop registered
initcall noop_init+0x0/0x14 returned 0 after 2905 usecs
calling  as_init+0x0/0x14 @ 1
io scheduler anticipatory registered
initcall as_init+0x0/0x14 returned 0 after 3605 usecs
calling  deadline_init+0x0/0x14 @ 1
io scheduler deadline registered
initcall deadline_init+0x0/0x14 returned 0 after 3246 usecs
calling  cfq_init+0x0/0x94 @ 1
io scheduler cfq registered (default)
initcall cfq_init+0x0/0x94 returned 0 after 3731 usecs
calling  libcrc32c_mod_init+0x0/0x2c @ 1
initcall libcrc32c_mod_init+0x0/0x2c returned 0 after 17 usecs
calling  percpu_counter_startup+0x0/0x38 @ 1
initcall percpu_counter_startup+0x0/0x38 returned 0 after 16 usecs
calling  pci_init+0x0/0x3a @ 1
pci 0000:0a:01.0: Boot video device
initcall pci_init+0x0/0x3a returned 0 after 3952 usecs
calling  pci_proc_init+0x0/0x6b @ 1
initcall pci_proc_init+0x0/0x6b returned 0 after 104 usecs
calling  pcie_portdrv_init+0x0/0x4c @ 1
pcieport-driver 0000:00:01.0: setting latency timer to 64
pcieport-driver 0000:00:01.0: irq 72 for MSI/MSI-X
pcieport-driver 0000:00:03.0: setting latency timer to 64
pcieport-driver 0000:00:03.0: irq 73 for MSI/MSI-X
pcieport-driver 0000:00:05.0: setting latency timer to 64
pcieport-driver 0000:00:05.0: irq 74 for MSI/MSI-X
pcieport-driver 0000:00:07.0: setting latency timer to 64
pcieport-driver 0000:00:07.0: irq 75 for MSI/MSI-X
pcieport-driver 0000:00:09.0: setting latency timer to 64
pcieport-driver 0000:00:09.0: irq 76 for MSI/MSI-X
pcieport-driver 0000:00:1c.0: setting latency timer to 64
pcieport-driver 0000:00:1c.0: irq 77 for MSI/MSI-X
pcieport-driver 0000:00:1c.4: setting latency timer to 64
pcieport-driver 0000:00:1c.4: irq 78 for MSI/MSI-X
initcall pcie_portdrv_init+0x0/0x4c returned 0 after 72411 usecs
calling  aer_service_init+0x0/0x20 @ 1
initcall aer_service_init+0x0/0x20 returned 0 after 62 usecs
calling  pci_hotplug_init+0x0/0x1d @ 1
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
initcall pci_hotplug_init+0x0/0x1d returned 0 after 4535 usecs
calling  genericbl_init+0x0/0x12 @ 1
initcall genericbl_init+0x0/0x12 returned 0 after 64 usecs
calling  acpi_reserve_resources+0x0/0xeb @ 1
initcall acpi_reserve_resources+0x0/0xeb returned 0 after 18 usecs
calling  acpi_fan_init+0x0/0x5e @ 1
initcall acpi_fan_init+0x0/0x5e returned 0 after 81 usecs
calling  irqrouter_init_sysfs+0x0/0x38 @ 1
initcall irqrouter_init_sysfs+0x0/0x38 returned 0 after 97 usecs
calling  acpi_processor_init+0x0/0xe8 @ 1
ACPI: SSDT BF45D618, 0574 (r1    AMI      IST        1 MSFT  3000001)
ACPI: CPU0 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:00: registered as cooling_device0
ACPI: Processor [CPU0] (supports 8 throttling states)
ACPI: CPU1 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:01: registered as cooling_device1
ACPI: Processor [CPU1] (supports 8 throttling states)
ACPI: CPU2 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:02: registered as cooling_device2
ACPI: Processor [CPU2] (supports 8 throttling states)
ACPI: CPU3 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:03: registered as cooling_device3
ACPI: Processor [CPU3] (supports 8 throttling states)
ACPI: CPU4 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:04: registered as cooling_device4
ACPI: Processor [CPU4] (supports 8 throttling states)
ACPI: CPU5 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:05: registered as cooling_device5
ACPI: Processor [CPU5] (supports 8 throttling states)
ACPI: CPU6 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:06: registered as cooling_device6
ACPI: Processor [CPU6] (supports 8 throttling states)
ACPI: CPU7 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:07: registered as cooling_device7
ACPI: Processor [CPU7] (supports 8 throttling states)
ACPI: CPU8 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:08: registered as cooling_device8
ACPI: Processor [CPU8] (supports 8 throttling states)
ACPI: CPU9 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:09: registered as cooling_device9
ACPI: Processor [CPU9] (supports 8 throttling states)
ACPI: CPU10 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:0a: registered as cooling_device10
ACPI: Processor [CPUA] (supports 8 throttling states)
ACPI: CPU11 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:0b: registered as cooling_device11
ACPI: Processor [CPUB] (supports 8 throttling states)
ACPI: CPU12 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:0c: registered as cooling_device12
ACPI: Processor [CPUC] (supports 8 throttling states)
ACPI: CPU13 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:0d: registered as cooling_device13
ACPI: Processor [CPUD] (supports 8 throttling states)
ACPI: CPU14 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:0e: registered as cooling_device14
ACPI: Processor [CPUE] (supports 8 throttling states)
ACPI: CPU15 (power states: C1[C1] C2[C2] C3[C3] C4[C3])
processor ACPI_CPU:0f: registered as cooling_device15
ACPI: Processor [CPUF] (supports 8 throttling states)
initcall acpi_processor_init+0x0/0xe8 returned 0 after 270089 usecs
calling  acpi_container_init+0x0/0x42 @ 1
initcall acpi_container_init+0x0/0x42 returned 0 after 2668 usecs
calling  acpi_thermal_init+0x0/0x83 @ 1
initcall acpi_thermal_init+0x0/0x83 returned 0 after 310 usecs
calling  rand_initialize+0x0/0x31 @ 1
initcall rand_initialize+0x0/0x31 returned 0 after 26 usecs
calling  tty_init+0x0/0xf5 @ 1
initcall tty_init+0x0/0xf5 returned 0 after 13322 usecs
calling  pty_init+0x0/0x336 @ 1
initcall pty_init+0x0/0x336 returned 0 after 328 usecs
calling  sysrq_init+0x0/0x25 @ 1
initcall sysrq_init+0x0/0x25 returned 0 after 22 usecs
calling  nvram_init+0x0/0x82 @ 1
Non-volatile memory driver v1.3
initcall nvram_init+0x0/0x82 returned 0 after 3466 usecs
calling  agp_init+0x0/0x26 @ 1
Linux agpgart interface v0.103
initcall agp_init+0x0/0x26 returned 0 after 2956 usecs
calling  agp_intel_init+0x0/0x29 @ 1
initcall agp_intel_init+0x0/0x29 returned 0 after 405 usecs
calling  agp_sis_init+0x0/0x29 @ 1
initcall agp_sis_init+0x0/0x29 returned 0 after 380 usecs
calling  agp_via_init+0x0/0x29 @ 1
initcall agp_via_init+0x0/0x29 returned 0 after 379 usecs
calling  cn_proc_init+0x0/0x3d @ 1
initcall cn_proc_init+0x0/0x3d returned 0 after 18 usecs
calling  serial8250_init+0x0/0x121 @ 1
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
async_waiting @ 1
async_continuing @ 1 after 0 usec
async_waiting @ 1
async_continuing @ 1 after 0 usec
serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
async_waiting @ 1
async_continuing @ 1 after 0 usec
async_waiting @ 1
async_continuing @ 1 after 0 usec
serial8250: ttyS1 at I/O 0x2f8 (irq =3D 7) is a 16550A
initcall serial8250_init+0x0/0x121 returned 0 after 531004 usecs
calling  serial8250_pnp_init+0x0/0x12 @ 1
00:05: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
initcall serial8250_pnp_init+0x0/0x12 returned 0 after 5541 usecs
calling  serial8250_pci_init+0x0/0x1b @ 1
initcall serial8250_pci_init+0x0/0x1b returned 0 after 404 usecs
calling  topology_sysfs_init+0x0/0x63 @ 1
initcall topology_sysfs_init+0x0/0x63 returned 0 after 73 usecs
calling  brd_init+0x0/0x193 @ 1
brd: module loaded
initcall brd_init+0x0/0x193 returned 0 after 11170 usecs
calling  cpqarray_init+0x0/0x299 @ 1
Compaq SMART2 Driver (v 2.6.0)
initcall cpqarray_init+0x0/0x299 returned -19 after 3625 usecs
calling  e1000_init_module+0x0/0x6b @ 1
e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k6
e1000e: Copyright (c) 1999-2008 Intel Corporation.
initcall e1000_init_module+0x0/0x6b returned 0 after 9858 usecs
calling  igb_init_module+0x0/0x56 @ 1
Intel(R) Gigabit Ethernet Network Driver - version 1.2.45-k2
Copyright (c) 2008 Intel Corporation.
igb 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
igb 0000:01:00.0: Disabling ASPM L0s upstream switch port 0000:00:01.0
igb 0000:01:00.0: pci_enable_pcie_error_reporting failed 0xfffffffb
igb 0000:01:00.0: setting latency timer to 64
igb 0000:01:00.0: irq 79 for MSI/MSI-X
igb 0000:01:00.0: irq 80 for MSI/MSI-X
igb 0000:01:00.0: irq 81 for MSI/MSI-X
igb 0000:01:00.0: irq 82 for MSI/MSI-X
igb 0000:01:00.0: irq 83 for MSI/MSI-X
igb 0000:01:00.0: irq 84 for MSI/MSI-X
igb 0000:01:00.0: irq 85 for MSI/MSI-X
igb 0000:01:00.0: irq 86 for MSI/MSI-X
igb 0000:01:00.0: irq 87 for MSI/MSI-X
igb 0000:01:00.0: Intel(R) Gigabit Ethernet Network Connection
igb 0000:01:00.0: eth0: (PCIe:2.5Gb/s:Width x4) 00:30:48:c3:7d:c2
igb 0000:01:00.0: eth0: PBA No: ffffff-0ff
igb 0000:01:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
igb 0000:01:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
igb 0000:01:00.1: Disabling ASPM L0s upstream switch port 0000:00:01.0
igb 0000:01:00.1: pci_enable_pcie_error_reporting failed 0xfffffffb
igb 0000:01:00.1: setting latency timer to 64
igb 0000:01:00.1: irq 88 for MSI/MSI-X
igb 0000:01:00.1: irq 89 for MSI/MSI-X
igb 0000:01:00.1: irq 90 for MSI/MSI-X
igb 0000:01:00.1: irq 91 for MSI/MSI-X
igb 0000:01:00.1: irq 92 for MSI/MSI-X
igb 0000:01:00.1: irq 93 for MSI/MSI-X
igb 0000:01:00.1: irq 94 for MSI/MSI-X
igb 0000:01:00.1: irq 95 for MSI/MSI-X
igb 0000:01:00.1: irq 96 for MSI/MSI-X
igb 0000:01:00.1: Intel(R) Gigabit Ethernet Network Connection
igb 0000:01:00.1: eth1: (PCIe:2.5Gb/s:Width x4) 00:30:48:c3:7d:c3
igb 0000:01:00.1: eth1: PBA No: ffffff-0ff
igb 0000:01:00.1: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
initcall igb_init_module+0x0/0x56 returned 0 after 394802 usecs
calling  vortex_init+0x0/0xad @ 1
initcall vortex_init+0x0/0xad returned 0 after 381 usecs
calling  e100_init_module+0x0/0x5d @ 1
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k6-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
initcall e100_init_module+0x0/0x5d returned 0 after 9460 usecs
calling  tg3_init+0x0/0x1b @ 1
initcall tg3_init+0x0/0x1b returned 0 after 391 usecs
calling  net_olddevs_init+0x0/0x9e @ 1
initcall net_olddevs_init+0x0/0x9e returned 0 after 20 usecs
calling  init_nic+0x0/0x1b @ 1
initcall init_nic+0x0/0x1b returned 0 after 385 usecs
calling  rtl8139_init_module+0x0/0x1b @ 1
initcall rtl8139_init_module+0x0/0x1b returned 0 after 379 usecs
calling  init_netconsole+0x0/0x1d9 @ 1
console [netcon0] enabled
netconsole: network logging started
initcall init_netconsole+0x0/0x1d9 returned 0 after 5785 usecs
calling  spi_transport_init+0x0/0x2e @ 1
initcall spi_transport_init+0x0/0x2e returned 0 after 721 usecs
calling  ahc_linux_init+0x0/0x66 @ 1
initcall ahc_linux_init+0x0/0x66 returned 0 after 478 usecs
calling  init_sd+0x0/0xff @ 1
Driver 'sd' needs updating - please use bus_type methods
initcall init_sd+0x0/0xff returned 0 after 5824 usecs
calling  ahci_init+0x0/0x1b @ 1
initcall ahci_init+0x0/0x1b returned 0 after 316 usecs
calling  piix_init+0x0/0x29 @ 1
ata_piix 0000:00:1f.2: version 2.12
IOAPIC[0]: Set routing entry (0-19 -> 0x72 -> IRQ 19 Mode:1 Active:1)
ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
ata_piix 0000:00:1f.2: setting latency timer to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf150 irq 14
ata2: SATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xf158 irq 15
ata1.00: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata1.01: SATA link down (SStatus 0 SControl 300)
ata1.00: ATA-6: ST3500320NS, SN04, max UDMA/133
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata1.00: configured for UDMA/133
async_waiting @ 35
async_continuing @ 35 after 0 usec
scsi 0:0:0:0: Direct-Access     ATA      ST3500320NS      SN04 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors: (500 GB/465 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't suppor=
t DPO or FUA
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors: (500 GB/465 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't suppor=
t DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
async_waiting @ 35
async_continuing @ 35 after 0 usec
ata2.00: SATA link down (SStatus 0 SControl 300)
ata2.01: SATA link down (SStatus 0 SControl 300)
async_waiting @ 35
async_continuing @ 35 after 0 usec
ata_piix 0000:00:1f.5: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
ata_piix 0000:00:1f.5: setting latency timer to 64
scsi2 : ata_piix
scsi3 : ata_piix
ata3: SATA max UDMA/133 cmd 0xf130 ctl 0xf120 bmdma 0xf0f0 irq 19
ata4: SATA max UDMA/133 cmd 0xf110 ctl 0xf100 bmdma 0xf0f8 irq 19
ata3: SATA link down (SStatus 0 SControl 300)
async_waiting @ 35
async_continuing @ 35 after 0 usec
async_waiting @ 35
async_continuing @ 35 after 0 usec
ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata4.00: ATAPI: SlimtypeDVD A  DS8A1P, CX17, max UDMA/33
ata4.00: applying bridge limits
ata4.00: configured for UDMA/33
async_waiting @ 35
async_continuing @ 35 after 0 usec
scsi 3:0:0:0: CD-ROM            Slimtype DVD A  DS8A1P    CX17 PQ: 0 ANSI: 5
initcall piix_init+0x0/0x29 returned 0 after 3020727 usecs
calling  nv_init+0x0/0x1b @ 1
initcall nv_init+0x0/0x1b returned 0 after 467 usecs
calling  amd_init+0x0/0x1b @ 1
initcall amd_init+0x0/0x1b returned 0 after 307 usecs
calling  oldpiix_init+0x0/0x1b @ 1
initcall oldpiix_init+0x0/0x1b returned 0 after 434 usecs
calling  nonstatic_sysfs_init+0x0/0x12 @ 1
initcall nonstatic_sysfs_init+0x0/0x12 returned 0 after 17 usecs
calling  yenta_socket_init+0x0/0x1b @ 1
initcall yenta_socket_init+0x0/0x1b returned 0 after 323 usecs
calling  mon_init+0x0/0x105 @ 1
initcall mon_init+0x0/0x105 returned 0 after 532 usecs
calling  ehci_hcd_init+0x0/0x77 @ 1
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
IOAPIC[0]: Set routing entry (0-18 -> 0x7a -> IRQ 18 Mode:1 Active:1)
ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ehci_hcd 0000:00:1a.7: setting latency timer to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.7: debug port 1
ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfbf22400
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
IOAPIC[0]: Set routing entry (0-23 -> 0x82 -> IRQ 23 Mode:1 Active:1)
ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
ehci_hcd 0000:00:1d.7: setting latency timer to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.7: debug port 1
ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfbf22000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
initcall ehci_hcd_init+0x0/0x77 returned 0 after 176618 usecs
calling  ohci_hcd_mod_init+0x0/0x56 @ 1
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
initcall ohci_hcd_mod_init+0x0/0x56 returned 0 after 5255 usecs
calling  uhci_hcd_init+0x0/0xc0 @ 1
uhci_hcd: USB Universal Host Controller Interface driver
uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
uhci_hcd 0000:00:1a.0: setting latency timer to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000f0c0
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
IOAPIC[0]: Set routing entry (0-21 -> 0x8a -> IRQ 21 Mode:1 Active:1)
uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
uhci_hcd 0000:00:1a.1: setting latency timer to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000f0a0
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.2: PCI INT D -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1a.2: setting latency timer to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 19, io base 0x0000f080
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
uhci_hcd 0000:00:1d.0: setting latency timer to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000f060
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1d.1: setting latency timer to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000f040
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
uhci_hcd 0000:00:1d.2: setting latency timer to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000f020
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
initcall uhci_hcd_init+0x0/0xc0 returned 0 after 282083 usecs
calling  usb_usual_init+0x0/0x3e @ 1
usbcore: registered new interface driver libusual
initcall usb_usual_init+0x0/0x3e returned 0 after 4775 usecs
calling  i8042_init+0x0/0x386 @ 1
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
initcall i8042_init+0x0/0x386 returned 0 after 19165 usecs
calling  serport_init+0x0/0x34 @ 1
initcall serport_init+0x0/0x34 returned 0 after 17 usecs
calling  mousedev_init+0x0/0x62 @ 1
mice: PS/2 mouse device common for all mice
initcall mousedev_init+0x0/0x62 returned 0 after 4671 usecs
calling  evdev_init+0x0/0x12 @ 1
initcall evdev_init+0x0/0x12 returned 0 after 16 usecs
calling  atkbd_init+0x0/0x27 @ 1
initcall atkbd_init+0x0/0x27 returned 0 after 493 usecs
calling  psmouse_init+0x0/0x70 @ 1
initcall psmouse_init+0x0/0x70 returned 0 after 440 usecs
calling  hid_init+0x0/0x67 @ 1
initcall hid_init+0x0/0x67 returned 0 after 358 usecs
calling  a4_init+0x0/0x20 @ 1
initcall a4_init+0x0/0x20 returned 0 after 212 usecs
calling  apple_init+0x0/0x3d @ 1
initcall apple_init+0x0/0x3d returned 0 after 598 usecs
calling  belkin_init+0x0/0x20 @ 1
initcall belkin_init+0x0/0x20 returned 0 after 369 usecs
calling  ch_init+0x0/0x20 @ 1
initcall ch_init+0x0/0x20 returned 0 after 398 usecs
calling  ch_init+0x0/0x20 @ 1
initcall ch_init+0x0/0x20 returned 0 after 298 usecs
calling  cp_init+0x0/0x20 @ 1
initcall cp_init+0x0/0x20 returned 0 after 130 usecs
calling  ez_init+0x0/0x20 @ 1
initcall ez_init+0x0/0x20 returned 0 after 386 usecs
calling  gyration_init+0x0/0x20 @ 1
initcall gyration_init+0x0/0x20 returned 0 after 284 usecs
calling  lg_init+0x0/0x20 @ 1
initcall lg_init+0x0/0x20 returned 0 after 255 usecs
calling  ms_init+0x0/0x20 @ 1
initcall ms_init+0x0/0x20 returned 0 after 310 usecs
calling  mr_init+0x0/0x20 @ 1
initcall mr_init+0x0/0x20 returned 0 after 293 usecs
calling  ntrig_init+0x0/0x20 @ 1
initcall ntrig_init+0x0/0x20 returned 0 after 291 usecs
calling  pl_init+0x0/0x20 @ 1
initcall pl_init+0x0/0x20 returned 0 after 659 usecs
calling  pl_init+0x0/0x20 @ 1
initcall pl_init+0x0/0x20 returned 0 after 204 usecs
calling  samsung_init+0x0/0x20 @ 1
initcall samsung_init+0x0/0x20 returned 0 after 104 usecs
calling  sony_init+0x0/0x20 @ 1
initcall sony_init+0x0/0x20 returned 0 after 73 usecs
calling  sp_init+0x0/0x20 @ 1
initcall sp_init+0x0/0x20 returned 0 after 173 usecs
calling  tm_init+0x0/0x20 @ 1
initcall tm_init+0x0/0x20 returned 0 after 94 usecs
calling  ts_init+0x0/0x20 @ 1
initcall ts_init+0x0/0x20 returned 0 after 73 usecs
calling  zp_init+0x0/0x20 @ 1
initcall zp_init+0x0/0x20 returned 0 after 233 usecs
calling  hid_init+0x0/0x88 @ 1
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
initcall hid_init+0x0/0x88 returned 0 after 16837 usecs
calling  usb_mouse_init+0x0/0x38 @ 1
usbcore: registered new interface driver usbmouse
usbmouse: v1.6:USB HID Boot Protocol mouse driver
initcall usb_mouse_init+0x0/0x38 returned 0 after 10910 usecs
calling  flow_cache_init+0x0/0x1cd @ 1
initcall flow_cache_init+0x0/0x1cd returned 0 after 176 usecs
calling  llc_init+0x0/0x20 @ 1
initcall llc_init+0x0/0x20 returned 0 after 16 usecs
calling  snap_init+0x0/0x31 @ 1
initcall snap_init+0x0/0x31 returned 0 after 16 usecs
calling  rif_init+0x0/0x95 @ 1
initcall rif_init+0x0/0x95 returned 0 after 28 usecs
calling  blackhole_module_init+0x0/0x12 @ 1
initcall blackhole_module_init+0x0/0x12 returned 0 after 16 usecs
calling  nf_conntrack_standalone_init+0x0/0x12 @ 1
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
nf_conntrack.acct=3D1 kernel paramater, acct=3D1 nf_conntrack module option=
 or
sysctl net.netfilter.nf_conntrack_acct=3D1 to enable it.
initcall nf_conntrack_standalone_init+0x0/0x12 returned 0 after 25250 usecs
calling  sysctl_ipv4_init+0x0/0x4e @ 1
initcall sysctl_ipv4_init+0x0/0x4e returned 0 after 228 usecs
calling  init_syncookies+0x0/0x19 @ 1
initcall init_syncookies+0x0/0x19 returned 0 after 36 usecs
calling  ipv4_netfilter_init+0x0/0x17 @ 1
initcall ipv4_netfilter_init+0x0/0x17 returned 0 after 16 usecs
calling  bictcp_register+0x0/0x12 @ 1
TCP bic registered
initcall bictcp_register+0x0/0x12 returned 0 after 2210 usecs
calling  xfrm_user_init+0x0/0x4d @ 1
Initializing XFRM netlink socket
initcall xfrm_user_init+0x0/0x4d returned 0 after 3422 usecs
calling  packet_init+0x0/0x47 @ 1
NET: Registered protocol family 17
initcall packet_init+0x0/0x47 returned 0 after 3612 usecs
calling  powernowk8_init+0x0/0xa2 @ 1
initcall powernowk8_init+0x0/0xa2 returned -19 after 1530 usecs
calling  acpi_cpufreq_init+0x0/0xfe @ 1
initcall acpi_cpufreq_init+0x0/0xfe returned 0 after 8766 usecs
calling  hpet_insert_resource+0x0/0x23 @ 1
initcall hpet_insert_resource+0x0/0x23 returned 0 after 19 usecs
calling  update_mp_table+0x0/0x631 @ 1
initcall update_mp_table+0x0/0x631 returned 0 after 16 usecs
calling  lapic_insert_resource+0x0/0x40 @ 1
initcall lapic_insert_resource+0x0/0x40 returned 0 after 16 usecs
calling  init_lapic_nmi_sysfs+0x0/0x39 @ 1
initcall init_lapic_nmi_sysfs+0x0/0x39 returned 0 after 15 usecs
calling  ioapic_insert_resources+0x0/0x4f @ 1
initcall ioapic_insert_resources+0x0/0x4f returned 0 after 17 usecs
calling  io_apic_bug_finalize+0x0/0x1b @ 1
initcall io_apic_bug_finalize+0x0/0x1b returned 0 after 15 usecs
calling  check_early_ioremap_leak+0x0/0x67 @ 1
initcall check_early_ioremap_leak+0x0/0x67 returned 0 after 16 usecs
calling  sched_init_debug+0x0/0x24 @ 1
initcall sched_init_debug+0x0/0x24 returned 0 after 22 usecs
calling  init_oops_id+0x0/0x36 @ 1
initcall init_oops_id+0x0/0x36 returned 0 after 18 usecs
calling  disable_boot_consoles+0x0/0x3a @ 1
initcall disable_boot_consoles+0x0/0x3a returned 0 after 15 usecs
calling  pm_qos_power_init+0x0/0xca @ 1
initcall pm_qos_power_init+0x0/0xca returned 0 after 700 usecs
calling  debugfs_kprobe_init+0x0/0x89 @ 1
initcall debugfs_kprobe_init+0x0/0x89 returned 0 after 21 usecs
calling  taskstats_init+0x0/0x95 @ 1
registered taskstats version 1
initcall taskstats_init+0x0/0x95 returned 0 after 2927 usecs
calling  max_swapfiles_check+0x0/0x8 @ 1
initcall max_swapfiles_check+0x0/0x8 returned 0 after 15 usecs
calling  random32_reseed+0x0/0xb0 @ 1
initcall random32_reseed+0x0/0xb0 returned 0 after 67 usecs
calling  pci_sysfs_init+0x0/0x4c @ 1
initcall pci_sysfs_init+0x0/0x4c returned 0 after 166 usecs
calling  acpi_wakeup_device_init+0x0/0xa0 @ 1
initcall acpi_wakeup_device_init+0x0/0xa0 returned 0 after 27 usecs
calling  acpi_sleep_proc_init+0x0/0x55 @ 1
initcall acpi_sleep_proc_init+0x0/0x55 returned 0 after 18 usecs
calling  seqgen_init+0x0/0xf @ 1
initcall seqgen_init+0x0/0xf returned 0 after 23 usecs
calling  scsi_complete_async_scans+0x0/0x109 @ 1
initcall scsi_complete_async_scans+0x0/0x109 returned 0 after 15 usecs
calling  memmap_init+0x0/0xa7 @ 1
initcall memmap_init+0x0/0xa7 returned 0 after 55 usecs
calling  pci_mmcfg_late_insert_resources+0x0/0x15b @ 1
initcall pci_mmcfg_late_insert_resources+0x0/0x15b returned 1 after 15 usecs
initcall pci_mmcfg_late_insert_resources+0x0/0x15b returned with error code=
 1=20
calling  tcp_congestion_default+0x0/0x12 @ 1
initcall tcp_congestion_default+0x0/0x12 returned 0 after 16 usecs
async_waiting @ 1
async_continuing @ 1 after 0 usec
Freeing unused kernel memory: 496k freed
Write protecting the kernel read-only data: 1608k
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
EXT3 FS on sda1, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda2, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 4096564k swap on /dev/sda3.  Priority:-1 extents:1 across:4096564k=
=20
warning: `dbus-daemon' uses deprecated v2 capabilities in a way that may be=
 insecure.
mtrr: type mismatch for f0000000,2000000 old: write-back new: write-combini=
ng
igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=config

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.29-rc2
# Wed Jan 21 20:01:40 2009
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_FAST_CMPXCHG_LOCAL=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_GENERIC_SPINLOCK=y
# CONFIG_RWSEM_XCHGADD_ALGORITHM is not set
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_X86_SMP=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_BIOS_REBOOT=y
CONFIG_X86_TRAMPOLINE=y
# CONFIG_KTIME_SCALAR is not set
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
# CONFIG_TASK_XACCT is not set
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_TREE=y
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=20
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
# CONFIG_GROUP_SCHED is not set
# CONFIG_CGROUPS is not set
CONFIG_SYSFS_DEPRECATED=y
CONFIG_SYSFS_DEPRECATED_V2=y
CONFIG_RELAY=y
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
# CONFIG_EMBEDDED is not set
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_STRIP_GENERATED=y
CONFIG_KALLSYMS_EXTRA_PASS=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_COMPAT_BRK=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_ANON_INODES=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_MARKERS=y
CONFIG_OPROFILE=m
# CONFIG_OPROFILE_IBS is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_KPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_KRETPROBES=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=y
CONFIG_MODULE_SRCVERSION_ALL=y
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_IO_TRACE=y
# CONFIG_BLK_DEV_BSG is not set
# CONFIG_BLK_DEV_INTEGRITY is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_CLASSIC_RCU=y
# CONFIG_TREE_RCU is not set
# CONFIG_PREEMPT_RCU is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_PREEMPT_RCU_TRACE is not set
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
# CONFIG_SPARSE_IRQ is not set
CONFIG_X86_FIND_SMP_CONFIG=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_PC=y
# CONFIG_X86_ELAN is not set
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_VSMP is not set
CONFIG_SCHED_OMIT_FRAME_POINTER=y
# CONFIG_PARAVIRT_GUEST is not set
CONFIG_MEMTEST=y
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_CPU=y
CONFIG_X86_L1_CACHE_BYTES=128
CONFIG_X86_INTERNODE_CACHE_BYTES=128
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=7
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR_64=y
CONFIG_X86_DS=y
CONFIG_X86_PTRACE_BTS=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
# CONFIG_AMD_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_IOMMU_API=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=255
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=m
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_K8_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_UNEVICTABLE_LRU=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW_64K=y
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
# CONFIG_X86_PAT is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x200000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y

#
# Power management and ACPI options
#
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_SLEEP=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_HIBERNATION is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_ACPI_SYSTEM=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_SBS=m

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_DEBUG=y
CONFIG_CPU_FREQ_STAT=m
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=m
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m

#
# CPUFreq processor drivers
#
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_POWERNOW_K8=y
CONFIG_X86_POWERNOW_K8_ACPI=y
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_ACPI_CPUFREQ_PROC_INTF is not set
# CONFIG_X86_SPEEDSTEP_LIB is not set
# CONFIG_CPU_IDLE is not set

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_DMAR=y
CONFIG_DMAR_GFX_WA=y
CONFIG_DMAR_FLOPPY_WA=y
CONFIG_INTR_REMAP=y
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=m
CONFIG_PCIEAER=y
# CONFIG_PCIEASPM is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
CONFIG_PCI_LEGACY=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
CONFIG_ISA_DMA_API=y
CONFIG_K8_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA_DEBUG is not set
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_PCMCIA_IOCTL=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=m
CONFIG_I82092=m
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_FAKE=m
CONFIG_HOTPLUG_PCI_ACPI=m
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=m

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_NET_NS is not set
CONFIG_COMPAT_NET_DEV_OPS=y
CONFIG_PACKET=y
CONFIG_PACKET_MMAP=y
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_ASK_IP_FIB_HASH=y
# CONFIG_IP_FIB_TRIE is not set
CONFIG_IP_FIB_HASH=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=m
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_DEFAULT_BIC=y
# CONFIG_DEFAULT_CUBIC is not set
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=m
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
CONFIG_INET6_IPCOMP=m
# CONFIG_IPV6_MIP6 is not set
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
CONFIG_IPV6_SIT=m
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_DEBUG=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CT_ACCT=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CT_PROTO_DCCP is not set
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_SCTP=m
# CONFIG_NF_CT_PROTO_UDPLITE is not set
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
# CONFIG_NF_CT_NETLINK is not set
# CONFIG_NETFILTER_TPROXY is not set
CONFIG_NETFILTER_XTABLES=m
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
# CONFIG_NETFILTER_XT_TARGET_RATEEST is not set
# CONFIG_NETFILTER_XT_TARGET_TRACE is not set
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
# CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP is not set
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
# CONFIG_NETFILTER_XT_MATCH_CONNLIMIT is not set
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
# CONFIG_NETFILTER_XT_MATCH_IPRANGE is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
# CONFIG_NETFILTER_XT_MATCH_OWNER is not set
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
CONFIG_NETFILTER_XT_MATCH_REALM=m
# CONFIG_NETFILTER_XT_MATCH_RECENT is not set
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
# CONFIG_NETFILTER_XT_MATCH_TIME is not set
# CONFIG_NETFILTER_XT_MATCH_U32 is not set
CONFIG_IP_VS=m
# CONFIG_IP_VS_IPV6 is not set
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_CONNTRACK_IPV4=m
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_QUEUE=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_ADDRTYPE=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_LOG=m
CONFIG_IP_NF_TARGET_ULOG=m
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PROTO_GRE=m
CONFIG_NF_NAT_PROTO_SCTP=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_NF_NAT_SIP=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_RAW=m
# CONFIG_IP_NF_SECURITY is not set
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_CONNTRACK_IPV6=m
CONFIG_IP6_NF_QUEUE=m
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_RT=m
CONFIG_IP6_NF_TARGET_LOG=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_RAW=m
# CONFIG_IP6_NF_SECURITY is not set

#
# DECnet: Netfilter Configuration
#
# CONFIG_DECNET_NF_GRABULATOR is not set
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
# CONFIG_BRIDGE_EBT_IP6 is not set
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_ULOG=m
# CONFIG_BRIDGE_EBT_NFLOG is not set
CONFIG_IP_DCCP=m
CONFIG_INET_DCCP_DIAG=m

#
# DCCP CCIDs Configuration (EXPERIMENTAL)
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_CCID3_RTO=100
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
# CONFIG_NET_DCCPPROBE is not set
CONFIG_IP_SCTP=m
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=y
CONFIG_TIPC=m
# CONFIG_TIPC_ADVANCED is not set
# CONFIG_TIPC_DEBUG is not set
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=m
# CONFIG_ATM_MPOA is not set
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_STP=m
CONFIG_BRIDGE=m
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=m
# CONFIG_VLAN_8021Q_GVRP is not set
CONFIG_DECNET=m
CONFIG_DECNET_ROUTER=y
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_IPX=m
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=m
CONFIG_DEV_APPLETALK=m
CONFIG_IPDDP=m
CONFIG_IPDDP_ENCAP=y
CONFIG_IPDDP_DECAP=y
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
CONFIG_WAN_ROUTER=m
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
# CONFIG_NET_SCH_MULTIQ is not set
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
# CONFIG_NET_SCH_DRR is not set
CONFIG_NET_SCH_INGRESS=m

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_ROUTE=y
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
# CONFIG_NET_CLS_FLOW is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
CONFIG_NET_ACT_IPT=m
# CONFIG_NET_ACT_NAT is not set
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
# CONFIG_NET_ACT_SKBEDIT is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set

#
# Network testing
#
CONFIG_NET_PKTGEN=m
# CONFIG_NET_TCPPROBE is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
CONFIG_IRDA=m

#
# IrDA protocols
#
CONFIG_IRLAN=m
CONFIG_IRNET=m
CONFIG_IRCOMM=m
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=m

#
# Dongle support
#
CONFIG_DONGLE=y
CONFIG_ESI_DONGLE=m
CONFIG_ACTISYS_DONGLE=m
CONFIG_TEKRAM_DONGLE=m
CONFIG_TOIM3232_DONGLE=m
CONFIG_LITELINK_DONGLE=m
CONFIG_MA600_DONGLE=m
CONFIG_GIRBIL_DONGLE=m
CONFIG_MCP2120_DONGLE=m
CONFIG_OLD_BELKIN_DONGLE=m
CONFIG_ACT200L_DONGLE=m
# CONFIG_KINGSUN_DONGLE is not set
# CONFIG_KSDAZZLE_DONGLE is not set
# CONFIG_KS959_DONGLE is not set

#
# FIR device drivers
#
CONFIG_USB_IRDA=m
CONFIG_SIGMATEL_FIR=m
CONFIG_NSC_FIR=m
CONFIG_WINBOND_FIR=m
CONFIG_SMC_IRCC_FIR=m
CONFIG_ALI_FIR=m
CONFIG_VLSI_FIR=m
CONFIG_VIA_FIR=m
CONFIG_MCS_FIR=m
CONFIG_BT=m
CONFIG_BT_L2CAP=m
CONFIG_BT_SCO=m
CONFIG_BT_RFCOMM=m
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=m
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_HIDP=m

#
# Bluetooth device drivers
#
# CONFIG_BT_HCIBTUSB is not set
# CONFIG_BT_HCIBTSDIO is not set
CONFIG_BT_HCIUART=m
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
# CONFIG_BT_HCIUART_LL is not set
CONFIG_BT_HCIBCM203X=m
CONFIG_BT_HCIBPA10X=m
CONFIG_BT_HCIBFUSB=m
CONFIG_BT_HCIDTL1=m
CONFIG_BT_HCIBT3C=m
CONFIG_BT_HCIBLUECARD=m
CONFIG_BT_HCIBTUART=m
CONFIG_BT_HCIVHCI=m
# CONFIG_AF_RXRPC is not set
# CONFIG_PHONET is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
CONFIG_WIRELESS_OLD_REGULATORY=y
CONFIG_WIRELESS_EXT=y
CONFIG_WIRELESS_EXT_SYSFS=y
# CONFIG_LIB80211 is not set
# CONFIG_MAC80211 is not set
# CONFIG_WIMAX is not set
CONFIG_RFKILL=m
# CONFIG_RFKILL_INPUT is not set
CONFIG_RFKILL_LEDS=y
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=m
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=m
# CONFIG_PARIDE is not set
CONFIG_BLK_CPQ_DA=y
CONFIG_BLK_CPQ_CISS_DA=m
CONFIG_CISS_SCSI_TAPE=y
CONFIG_BLK_DEV_DAC960=m
CONFIG_BLK_DEV_UMEM=m
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_CRYPTOLOOP=m
CONFIG_BLK_DEV_NBD=m
CONFIG_BLK_DEV_SX8=m
CONFIG_BLK_DEV_UB=m
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=m
# CONFIG_BLK_DEV_HD is not set
CONFIG_MISC_DEVICES=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_EEPROM_93CX6 is not set
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_SGI_XP is not set
# CONFIG_HP_ILO is not set
# CONFIG_SGI_GRU is not set
# CONFIG_DELL_LAPTOP is not set
# CONFIG_C2PORT is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=m
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=m
# CONFIG_SCSI_FC_TGT_ATTRS is not set
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
# CONFIG_SCSI_SAS_LIBSAS is not set
CONFIG_SCSI_SRP_ATTRS=m
# CONFIG_SCSI_SRP_TGT_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
# CONFIG_SCSI_CXGB3_ISCSI is not set
CONFIG_BLK_DEV_3W_XXXX_RAID=m
CONFIG_SCSI_3W_9XXX=m
CONFIG_SCSI_ACARD=m
CONFIG_SCSI_AACRAID=m
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=4
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC7XXX_OLD=m
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=m
# CONFIG_SCSI_ARCMSR_AER is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=m
CONFIG_MEGARAID_MAILBOX=m
CONFIG_MEGARAID_LEGACY=m
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_HPTIOP=m
CONFIG_SCSI_BUSLOGIC=m
# CONFIG_LIBFC is not set
# CONFIG_FCOE is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
CONFIG_SCSI_GDTH=m
CONFIG_SCSI_IPS=m
CONFIG_SCSI_INITIO=m
CONFIG_SCSI_INIA100=m
CONFIG_SCSI_PPA=m
CONFIG_SCSI_IMM=m
# CONFIG_SCSI_IZIP_EPP16 is not set
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
# CONFIG_SCSI_MVSAS is not set
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=m
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=m
CONFIG_SCSI_QLA_FC=m
CONFIG_SCSI_QLA_ISCSI=m
CONFIG_SCSI_LPFC=m
# CONFIG_SCSI_LPFC_DEBUG_FS is not set
CONFIG_SCSI_DC395x=m
CONFIG_SCSI_DC390T=m
# CONFIG_SCSI_DEBUG is not set
CONFIG_SCSI_SRP=m
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
# CONFIG_SCSI_DH is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y
CONFIG_SATA_AHCI=y
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y
CONFIG_SATA_SVW=m
CONFIG_ATA_PIIX=y
CONFIG_SATA_MV=m
CONFIG_SATA_NV=y
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SX4=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m
CONFIG_SATA_INIC162X=m
# CONFIG_PATA_ACPI is not set
CONFIG_PATA_ALI=m
CONFIG_PATA_AMD=y
CONFIG_PATA_ARTOP=m
CONFIG_PATA_ATIIXP=m
# CONFIG_PATA_CMD640_PCI is not set
CONFIG_PATA_CMD64X=m
CONFIG_PATA_CS5520=m
CONFIG_PATA_CS5530=m
CONFIG_PATA_CYPRESS=m
CONFIG_PATA_EFAR=m
CONFIG_ATA_GENERIC=m
CONFIG_PATA_HPT366=m
CONFIG_PATA_HPT37X=m
CONFIG_PATA_HPT3X2N=m
CONFIG_PATA_HPT3X3=m
# CONFIG_PATA_HPT3X3_DMA is not set
CONFIG_PATA_IT821X=m
CONFIG_PATA_IT8213=m
CONFIG_PATA_JMICRON=m
CONFIG_PATA_TRIFLEX=m
CONFIG_PATA_MARVELL=m
CONFIG_PATA_MPIIX=m
CONFIG_PATA_OLDPIIX=y
CONFIG_PATA_NETCELL=m
# CONFIG_PATA_NINJA32 is not set
CONFIG_PATA_NS87410=m
# CONFIG_PATA_NS87415 is not set
CONFIG_PATA_OPTI=m
CONFIG_PATA_OPTIDMA=m
CONFIG_PATA_PCMCIA=m
CONFIG_PATA_PDC_OLD=m
CONFIG_PATA_RADISYS=m
CONFIG_PATA_RZ1000=m
CONFIG_PATA_SC1200=m
CONFIG_PATA_SERVERWORKS=m
CONFIG_PATA_PDC2027X=m
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
CONFIG_PATA_VIA=m
CONFIG_PATA_WINBOND=m
# CONFIG_PATA_SCH is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_RAID5_RESHAPE=y
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_MIRROR=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
CONFIG_FUSION_FC=m
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=40
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LAN=m
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#

#
# Enable only one of the two stacks, unless you know what you are doing
#
# CONFIG_FIREWIRE is not set
CONFIG_IEEE1394=m
CONFIG_IEEE1394_OHCI1394=m
CONFIG_IEEE1394_PCILYNX=m
CONFIG_IEEE1394_SBP2=m
# CONFIG_IEEE1394_SBP2_PHYS_DMA is not set
CONFIG_IEEE1394_ETH1394_ROM_ENTRY=y
CONFIG_IEEE1394_ETH1394=m
CONFIG_IEEE1394_RAWIO=m
CONFIG_IEEE1394_VIDEO1394=m
CONFIG_IEEE1394_DV1394=m
# CONFIG_IEEE1394_VERBOSEDEBUG is not set
CONFIG_I2O=m
# CONFIG_I2O_LCT_NOTIFY_ON_CHANGES is not set
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_EXT_ADAPTEC_DMA64=y
# CONFIG_I2O_CONFIG is not set
CONFIG_I2O_BUS=m
CONFIG_I2O_BLOCK=m
CONFIG_I2O_SCSI=m
CONFIG_I2O_PROC=m
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_IFB=m
CONFIG_DUMMY=m
CONFIG_BONDING=m
# CONFIG_MACVLAN is not set
CONFIG_EQUALIZER=m
CONFIG_TUN=m
# CONFIG_VETH is not set
CONFIG_NET_SB1000=m
# CONFIG_ARCNET is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
CONFIG_MARVELL_PHY=m
CONFIG_DAVICOM_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_LXT_PHY=m
CONFIG_CICADA_PHY=m
CONFIG_VITESSE_PHY=m
CONFIG_SMSC_PHY=m
CONFIG_BROADCOM_PHY=m
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_FIXED_PHY is not set
# CONFIG_MDIO_BITBANG is not set
CONFIG_NET_ETHERNET=y
CONFIG_MII=y
CONFIG_HAPPYMEAL=m
CONFIG_SUNGEM=m
CONFIG_CASSINI=m
CONFIG_NET_VENDOR_3COM=y
CONFIG_VORTEX=y
CONFIG_TYPHOON=m
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_TULIP=m
# CONFIG_TULIP_MWI is not set
CONFIG_TULIP_MMIO=y
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_ULI526X=m
CONFIG_PCMCIA_XIRCOM=m
# CONFIG_HP100 is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
# CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
# CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
# CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
CONFIG_NET_PCI=y
CONFIG_PCNET32=m
CONFIG_AMD8111_ETH=m
CONFIG_ADAPTEC_STARFIRE=m
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_FORCEDETH=y
CONFIG_FORCEDETH_NAPI=y
CONFIG_E100=y
CONFIG_FEALNX=m
CONFIG_NATSEMI=m
CONFIG_NE2K_PCI=m
CONFIG_8139CP=m
CONFIG_8139TOO=y
# CONFIG_8139TOO_PIO is not set
# CONFIG_8139TOO_TUNE_TWISTER is not set
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
# CONFIG_R6040 is not set
CONFIG_SIS900=m
CONFIG_EPIC100=m
# CONFIG_SMSC9420 is not set
CONFIG_SUNDANCE=m
# CONFIG_SUNDANCE_MMIO is not set
# CONFIG_TLAN is not set
CONFIG_VIA_RHINE=m
CONFIG_VIA_RHINE_MMIO=y
CONFIG_SC92031=m
CONFIG_NET_POCKET=y
CONFIG_ATP=m
CONFIG_DE600=m
CONFIG_DE620=m
# CONFIG_ATL2 is not set
CONFIG_NETDEV_1000=y
CONFIG_ACENIC=m
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_DL2K=m
# CONFIG_E1000 is not set
CONFIG_E1000E=y
# CONFIG_IP1000 is not set
CONFIG_IGB=y
CONFIG_IGB_LRO=y
CONFIG_NS83820=m
CONFIG_HAMACHI=m
CONFIG_YELLOWFIN=m
CONFIG_R8169=m
CONFIG_R8169_VLAN=y
# CONFIG_SIS190 is not set
CONFIG_SKGE=m
# CONFIG_SKGE_DEBUG is not set
CONFIG_SKY2=m
# CONFIG_SKY2_DEBUG is not set
CONFIG_VIA_VELOCITY=m
CONFIG_TIGON3=y
CONFIG_BNX2=m
CONFIG_QLA3XXX=m
CONFIG_ATL1=m
# CONFIG_ATL1E is not set
# CONFIG_JME is not set
CONFIG_NETDEV_10000=y
CONFIG_CHELSIO_T1=m
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3_DEPENDS=y
CONFIG_CHELSIO_T3=m
# CONFIG_ENIC is not set
# CONFIG_IXGBE is not set
CONFIG_IXGB=m
CONFIG_S2IO=m
CONFIG_MYRI10GE=m
CONFIG_NETXEN_NIC=m
# CONFIG_NIU is not set
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_TEHUTI is not set
# CONFIG_BNX2X is not set
# CONFIG_QLGE is not set
# CONFIG_SFC is not set
CONFIG_TR=y
CONFIG_IBMOL=m
CONFIG_3C359=m
# CONFIG_TMS380TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set
# CONFIG_IWLWIFI_LEDS is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#

#
# USB Network Adapters
#
CONFIG_USB_CATC=m
CONFIG_USB_KAWETH=m
CONFIG_USB_PEGASUS=m
CONFIG_USB_RTL8150=m
CONFIG_USB_USBNET=m
CONFIG_USB_NET_AX8817X=m
CONFIG_USB_NET_CDCETHER=m
CONFIG_USB_NET_DM9601=m
# CONFIG_USB_NET_SMSC95XX is not set
CONFIG_USB_NET_GL620A=m
CONFIG_USB_NET_NET1080=m
CONFIG_USB_NET_PLUSB=m
CONFIG_USB_NET_MCS7830=m
CONFIG_USB_NET_RNDIS_HOST=m
CONFIG_USB_NET_CDC_SUBSET=m
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=m
# CONFIG_USB_HSO is not set
CONFIG_NET_PCMCIA=y
CONFIG_PCMCIA_3C589=m
CONFIG_PCMCIA_3C574=m
CONFIG_PCMCIA_FMVJ18X=m
CONFIG_PCMCIA_PCNET=m
CONFIG_PCMCIA_NMCLAN=m
CONFIG_PCMCIA_SMC91C92=m
CONFIG_PCMCIA_XIRC2PS=m
CONFIG_PCMCIA_AXNET=m
# CONFIG_PCMCIA_IBMTR is not set
# CONFIG_WAN is not set
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
CONFIG_ATM_TCP=m
CONFIG_ATM_LANAI=m
CONFIG_ATM_ENI=m
# CONFIG_ATM_ENI_DEBUG is not set
# CONFIG_ATM_ENI_TUNE_BURST is not set
CONFIG_ATM_FIRESTREAM=m
# CONFIG_ATM_ZATM is not set
CONFIG_ATM_IDT77252=m
# CONFIG_ATM_IDT77252_DEBUG is not set
# CONFIG_ATM_IDT77252_RCV_ALL is not set
CONFIG_ATM_IDT77252_USE_SUNI=y
CONFIG_ATM_AMBASSADOR=m
# CONFIG_ATM_AMBASSADOR_DEBUG is not set
CONFIG_ATM_HORIZON=m
# CONFIG_ATM_HORIZON_DEBUG is not set
# CONFIG_ATM_IA is not set
# CONFIG_ATM_FORE200E is not set
CONFIG_ATM_HE=m
# CONFIG_ATM_HE_USE_SUNI is not set
# CONFIG_ATM_SOLOS is not set
CONFIG_FDDI=y
# CONFIG_DEFXX is not set
CONFIG_SKFP=m
# CONFIG_HIPPI is not set
CONFIG_PLIP=m
CONFIG_PPP=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_PPP_DEFLATE=m
# CONFIG_PPP_BSDCOMP is not set
CONFIG_PPP_MPPE=m
CONFIG_PPPOE=m
CONFIG_PPPOATM=m
# CONFIG_PPPOL2TP is not set
CONFIG_SLIP=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLHC=m
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_NET_FC=y
CONFIG_NETCONSOLE=y
# CONFIG_NETCONSOLE_DYNAMIC is not set
CONFIG_NETPOLL=y
CONFIG_NETPOLL_TRAP=y
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_STOWAWAY=m
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=m
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_VSXXXAA=m
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=m
CONFIG_JOYSTICK_A3D=m
CONFIG_JOYSTICK_ADI=m
CONFIG_JOYSTICK_COBRA=m
CONFIG_JOYSTICK_GF2K=m
CONFIG_JOYSTICK_GRIP=m
CONFIG_JOYSTICK_GRIP_MP=m
CONFIG_JOYSTICK_GUILLEMOT=m
CONFIG_JOYSTICK_INTERACT=m
CONFIG_JOYSTICK_SIDEWINDER=m
CONFIG_JOYSTICK_TMDC=m
CONFIG_JOYSTICK_IFORCE=m
CONFIG_JOYSTICK_IFORCE_USB=y
CONFIG_JOYSTICK_IFORCE_232=y
CONFIG_JOYSTICK_WARRIOR=m
CONFIG_JOYSTICK_MAGELLAN=m
CONFIG_JOYSTICK_SPACEORB=m
CONFIG_JOYSTICK_SPACEBALL=m
CONFIG_JOYSTICK_STINGER=m
CONFIG_JOYSTICK_TWIDJOY=m
# CONFIG_JOYSTICK_ZHENHUA is not set
CONFIG_JOYSTICK_DB9=m
CONFIG_JOYSTICK_GAMECON=m
CONFIG_JOYSTICK_TURBOGRAFX=m
CONFIG_JOYSTICK_JOYDUMP=m
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
# CONFIG_TOUCHSCREEN_FUJITSU is not set
CONFIG_TOUCHSCREEN_GUNZE=m
CONFIG_TOUCHSCREEN_ELO=m
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
CONFIG_TOUCHSCREEN_MTOUCH=m
# CONFIG_TOUCHSCREEN_INEXIO is not set
CONFIG_TOUCHSCREEN_MK712=m
CONFIG_TOUCHSCREEN_PENMOUNT=m
CONFIG_TOUCHSCREEN_TOUCHRIGHT=m
CONFIG_TOUCHSCREEN_TOUCHWIN=m
# CONFIG_TOUCHSCREEN_WM97XX is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_APANEL is not set
CONFIG_INPUT_ATLAS_BTNS=m
# CONFIG_INPUT_ATI_REMOTE is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_UINPUT=m

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_GAMEPORT=m
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=m
CONFIG_GAMEPORT_EMU10K1=m
CONFIG_GAMEPORT_FM801=m

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_DEVKMEM=y
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_COMPUTONE is not set
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
# CONFIG_CYZ_INTR is not set
# CONFIG_DIGIEPCA is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_ISI is not set
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
CONFIG_N_HDLC=m
# CONFIG_RISCOM8 is not set
# CONFIG_SPECIALIX is not set
# CONFIG_SX is not set
# CONFIG_RIO is not set
# CONFIG_STALDRV is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CS=m
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=m
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
CONFIG_PRINTER=m
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=m
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_NVRAM=y
CONFIG_R3964=m
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
# CONFIG_IPWIRELESS is not set
CONFIG_MWAVE=m
CONFIG_PC8736x_GPIO=m
CONFIG_NSC_GPIO=m
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS=m
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=m
# CONFIG_I2C_AMD756_S4882 is not set
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=m
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_PIIX4 is not set
CONFIG_I2C_NFORCE2=m
# CONFIG_I2C_NFORCE2_S4985 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_SIMTEC is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Graphics adapter I2C/DDC channel drivers
#
CONFIG_I2C_VOODOO3=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_PCA_PLATFORM is not set
CONFIG_I2C_STUB=m

#
# Miscellaneous I2C Chip support
#
# CONFIG_DS1682 is not set
# CONFIG_AT24 is not set
CONFIG_SENSORS_EEPROM=m
CONFIG_SENSORS_PCF8574=m
# CONFIG_PCF8575 is not set
# CONFIG_SENSORS_PCA9539 is not set
CONFIG_SENSORS_PCF8591=m
CONFIG_SENSORS_MAX6875=m
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set
# CONFIG_SPI is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
CONFIG_W1=m
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=m
CONFIG_W1_MASTER_DS2490=m
CONFIG_W1_MASTER_DS2482=m

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
CONFIG_W1_SLAVE_SMEM=m
CONFIG_W1_SLAVE_DS2433=m
CONFIG_W1_SLAVE_DS2433_CRC=y
# CONFIG_W1_SLAVE_DS2760 is not set
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
CONFIG_SENSORS_ABITUGURU=m
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7473 is not set
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS1621=m
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=m
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHER=m
CONFIG_SENSORS_FSCPOS=m
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IBMAEM is not set
# CONFIG_SENSORS_IBMPEX is not set
CONFIG_SENSORS_IT87=m
CONFIG_SENSORS_LM63=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_MAX1619=m
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_SIS5595=m
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83L785TS=m
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_HDAPS=m
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_HWMON_DEBUG_CHIP is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
CONFIG_WATCHDOG=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
# CONFIG_SC520_WDT is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=m
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=m
CONFIG_ITCO_WDT=m
CONFIG_ITCO_VENDOR_SUPPORT=y
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
CONFIG_PC87413_WDT=m
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
CONFIG_W83627HF_WDT=m
CONFIG_W83697HF_WDT=m
# CONFIG_W83697UG_WDT is not set
CONFIG_W83877F_WDT=m
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m
CONFIG_WDT_501_PCI=y

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
CONFIG_MFD_SM501=m
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_REGULATOR is not set

#
# Multimedia devices
#

#
# Multimedia core support
#
# CONFIG_VIDEO_DEV is not set
CONFIG_DVB_CORE=m
CONFIG_VIDEO_MEDIA=m

#
# Multimedia drivers
#
# CONFIG_MEDIA_ATTACH is not set
CONFIG_MEDIA_TUNER=m
# CONFIG_MEDIA_TUNER_CUSTOMIZE is not set
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
# CONFIG_DVB_DYNAMIC_MINORS is not set
CONFIG_DVB_CAPTURE_DRIVERS=y

#
# Supported SAA7146 based PCI Adapters
#
# CONFIG_TTPCI_EEPROM is not set
# CONFIG_DVB_BUDGET_CORE is not set

#
# Supported USB Adapters
#
# CONFIG_DVB_USB is not set
CONFIG_DVB_TTUSB_BUDGET=m
CONFIG_DVB_TTUSB_DEC=m
# CONFIG_DVB_SIANO_SMS1XXX is not set

#
# Supported FlexCopII (B2C2) Adapters
#
CONFIG_DVB_B2C2_FLEXCOP=m
CONFIG_DVB_B2C2_FLEXCOP_PCI=m
CONFIG_DVB_B2C2_FLEXCOP_USB=m
# CONFIG_DVB_B2C2_FLEXCOP_DEBUG is not set

#
# Supported BT878 Adapters
#

#
# Supported Pluto2 Adapters
#
CONFIG_DVB_PLUTO2=m

#
# Supported SDMC DM1105 Adapters
#
# CONFIG_DVB_DM1105 is not set

#
# Supported DVB Frontends
#

#
# Customise DVB Frontends
#
# CONFIG_DVB_FE_CUSTOMISE is not set

#
# Multistandard (satellite) frontends
#
# CONFIG_DVB_STB0899 is not set
# CONFIG_DVB_STB6100 is not set

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=m
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_S5H1420=m
# CONFIG_DVB_STV0288 is not set
# CONFIG_DVB_STB6000 is not set
CONFIG_DVB_STV0299=m
CONFIG_DVB_TDA8083=m
CONFIG_DVB_TDA10086=m
# CONFIG_DVB_TDA8261 is not set
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_TUA6100=m
# CONFIG_DVB_CX24116 is not set
# CONFIG_DVB_SI21XX is not set

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
# CONFIG_DVB_DRX397XD is not set
CONFIG_DVB_L64781=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_DIB3000MB=m
CONFIG_DVB_DIB3000MC=m
CONFIG_DVB_DIB7000M=m
CONFIG_DVB_DIB7000P=m
# CONFIG_DVB_TDA10048 is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=m
CONFIG_DVB_TDA10021=m
# CONFIG_DVB_TDA10023 is not set
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
# CONFIG_DVB_LGDT3304 is not set
# CONFIG_DVB_S5H1409 is not set
# CONFIG_DVB_AU8522 is not set
# CONFIG_DVB_S5H1411 is not set

#
# ISDB-T (terrestrial) frontends
#
# CONFIG_DVB_S921 is not set

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m
CONFIG_DVB_TUNER_DIB0070=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_LNBP21=m
# CONFIG_DVB_ISL6405 is not set
CONFIG_DVB_ISL6421=m
# CONFIG_DVB_LGS8GL5 is not set

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set
# CONFIG_DVB_AF9013 is not set
# CONFIG_DAB is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_DRM=m
CONFIG_DRM_TDFX=m
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_I810=m
CONFIG_DRM_I830=m
CONFIG_DRM_I915=m
# CONFIG_DRM_I915_KMS is not set
CONFIG_DRM_MGA=m
# CONFIG_DRM_SIS is not set
CONFIG_DRM_VIA=m
CONFIG_DRM_SAVAGE=m
CONFIG_VGASTATE=m
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=m
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=m
CONFIG_FB_CFB_COPYAREA=m
CONFIG_FB_CFB_IMAGEBLIT=m
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
CONFIG_FB_SVGALIB=m
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=m
CONFIG_FB_NVIDIA_I2C=y
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=m
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
CONFIG_FB_RIVA_BACKLIGHT=y
# CONFIG_FB_LE80578 is not set
CONFIG_FB_INTEL=m
# CONFIG_FB_INTEL_DEBUG is not set
CONFIG_FB_INTEL_I2C=y
CONFIG_FB_MATROX=m
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=m
CONFIG_FB_MATROX_MAVEN=m
CONFIG_FB_MATROX_MULTIHEAD=y
# CONFIG_FB_RADEON is not set
CONFIG_FB_ATY128=m
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=m
CONFIG_FB_ATY_CT=y
CONFIG_FB_ATY_GENERIC_LCD=y
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=m
CONFIG_FB_SAVAGE=m
CONFIG_FB_SAVAGE_I2C=y
CONFIG_FB_SAVAGE_ACCEL=y
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=m
CONFIG_FB_KYRO=m
CONFIG_FB_3DFX=m
CONFIG_FB_3DFX_ACCEL=y
CONFIG_FB_VOODOO1=m
# CONFIG_FB_VT8623 is not set
CONFIG_FB_TRIDENT=m
CONFIG_FB_TRIDENT_ACCEL=y
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
CONFIG_FB_SM501=m
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_ILI9320 is not set
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_PROGEAR=m
# CONFIG_BACKLIGHT_MBP_NVIDIA is not set
# CONFIG_BACKLIGHT_SAHARA is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y
# CONFIG_FRAMEBUFFER_CONSOLE is not set
CONFIG_FONT_8x16=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
CONFIG_SND_PCM_OSS=m
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_DYNAMIC_MINORS=y
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=m
CONFIG_SND_VIRMIDI=m
# CONFIG_SND_MTPAV is not set
CONFIG_SND_MTS64=m
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=m
CONFIG_SND_PORTMAN2X4=m
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
CONFIG_SND_SB_COMMON=m
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
CONFIG_SND_ALS300=m
CONFIG_SND_ALS4000=m
CONFIG_SND_ALI5451=m
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
CONFIG_SND_AU8830=m
# CONFIG_SND_AW2 is not set
CONFIG_SND_AZT3328=m
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=m
CONFIG_SND_CMIPCI=m
# CONFIG_SND_OXYGEN is not set
CONFIG_SND_CS4281=m
CONFIG_SND_CS46XX=m
CONFIG_SND_CS46XX_NEW_DSP=y
# CONFIG_SND_CS5530 is not set
CONFIG_SND_DARLA20=m
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
CONFIG_SND_ES1938=m
CONFIG_SND_ES1968=m
CONFIG_SND_FM801=m
CONFIG_SND_HDA_INTEL=m
# CONFIG_SND_HDA_HWDEP is not set
# CONFIG_SND_HDA_INPUT_BEEP is not set
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_ATIHDMI=y
CONFIG_SND_HDA_CODEC_NVHDMI=y
CONFIG_SND_HDA_CODEC_INTELHDMI=y
CONFIG_SND_HDA_ELD=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
# CONFIG_SND_HDA_POWER_SAVE is not set
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
# CONFIG_SND_HIFIER is not set
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=m
CONFIG_SND_MAESTRO3=m
CONFIG_SND_MIXART=m
CONFIG_SND_NM256=m
CONFIG_SND_PCXHR=m
CONFIG_SND_RIPTIDE=m
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
CONFIG_SND_SONICVIBES=m
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
# CONFIG_SND_VIRTUOSO is not set
CONFIG_SND_VX222=m
CONFIG_SND_YMFPCI=m
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
CONFIG_SND_USB_USX2Y=m
# CONFIG_SND_USB_CAIAQ is not set
# CONFIG_SND_USB_US122L is not set
CONFIG_SND_PCMCIA=y
# CONFIG_SND_VXPOCKET is not set
# CONFIG_SND_PDAUDIOCF is not set
CONFIG_SND_SOC=m
CONFIG_SND_SOC_I2C_AND_SPI=m
# CONFIG_SND_SOC_ALL_CODECS is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=m
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
# CONFIG_HID_DEBUG is not set
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# Special HID drivers
#
CONFIG_HID_COMPAT=y
CONFIG_HID_A4TECH=y
CONFIG_HID_APPLE=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_EZKEY=y
CONFIG_HID_GYRATION=y
CONFIG_HID_LOGITECH=y
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_NTRIG=y
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
CONFIG_HID_SUNPLUS=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_TOPSEED=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_ZEROPLUS_FF=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
CONFIG_USB_DEVICE_CLASS=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_OTG is not set
CONFIG_USB_MON=y
# CONFIG_USB_WUSB is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=m
# CONFIG_USB_ISP1760_HCD is not set
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=m
CONFIG_USB_SL811_HCD=m
CONFIG_USB_SL811_CS=m
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may also be needed;
#

#
# see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
# CONFIG_USB_STORAGE_ONETOUCH is not set
CONFIG_USB_STORAGE_KARMA=y
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
CONFIG_USB_LIBUSUAL=y

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_MICROTEK=m

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=m
CONFIG_USB_EZUSB=y
CONFIG_USB_SERIAL_GENERIC=y
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
# CONFIG_USB_SERIAL_CH341 is not set
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP2101=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_FUNSOFT=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
# CONFIG_USB_SERIAL_IUU is not set
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KEYSPAN_MPR=y
CONFIG_USB_SERIAL_KEYSPAN_USA28=y
CONFIG_USB_SERIAL_KEYSPAN_USA28X=y
CONFIG_USB_SERIAL_KEYSPAN_USA28XA=y
CONFIG_USB_SERIAL_KEYSPAN_USA28XB=y
CONFIG_USB_SERIAL_KEYSPAN_USA19=y
CONFIG_USB_SERIAL_KEYSPAN_USA18X=y
CONFIG_USB_SERIAL_KEYSPAN_USA19W=y
CONFIG_USB_SERIAL_KEYSPAN_USA19QW=y
CONFIG_USB_SERIAL_KEYSPAN_USA19QI=y
CONFIG_USB_SERIAL_KEYSPAN_USA49W=y
CONFIG_USB_SERIAL_KEYSPAN_USA49WLC=y
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
CONFIG_USB_SERIAL_MOS7720=m
CONFIG_USB_SERIAL_MOS7840=m
# CONFIG_USB_SERIAL_MOTOROLA is not set
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
# CONFIG_USB_SERIAL_OTI6858 is not set
# CONFIG_USB_SERIAL_SPCP8X5 is not set
CONFIG_USB_SERIAL_HP4X=m
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
# CONFIG_USB_SERIAL_SIEMENS_MPI is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
CONFIG_USB_SERIAL_TI=m
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
# CONFIG_USB_SERIAL_OPTICON is not set
CONFIG_USB_SERIAL_DEBUG=m

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
# CONFIG_USB_SEVSEG is not set
CONFIG_USB_RIO500=m
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
CONFIG_USB_BERRY_CHARGE=m
CONFIG_USB_LED=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_PHIDGET=m
CONFIG_USB_PHIDGETKIT=m
CONFIG_USB_PHIDGETMOTORCONTROL=m
CONFIG_USB_PHIDGETSERVO=m
CONFIG_USB_IDMOUSE=m
CONFIG_USB_FTDI_ELAN=m
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
CONFIG_USB_TRANCEVIBRATOR=m
CONFIG_USB_IOWARRIOR=m
CONFIG_USB_TEST=m
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_VST is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_UWB is not set
CONFIG_MMC=m
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_BOUNCE=y
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=m
# CONFIG_MMC_SDHCI_PCI is not set
CONFIG_MMC_WBSD=m
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_ALIX2 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=m
CONFIG_INFINIBAND_USER_MAD=m
CONFIG_INFINIBAND_USER_ACCESS=m
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_MTHCA=m
CONFIG_INFINIBAND_MTHCA_DEBUG=y
CONFIG_INFINIBAND_IPATH=m
# CONFIG_INFINIBAND_AMSO1100 is not set
CONFIG_INFINIBAND_CXGB3=m
# CONFIG_INFINIBAND_CXGB3_DEBUG is not set
# CONFIG_MLX4_INFINIBAND is not set
# CONFIG_INFINIBAND_NES is not set
CONFIG_INFINIBAND_IPOIB=m
CONFIG_INFINIBAND_IPOIB_CM=y
CONFIG_INFINIBAND_IPOIB_DEBUG=y
CONFIG_INFINIBAND_IPOIB_DEBUG_DATA=y
CONFIG_INFINIBAND_SRP=m
CONFIG_INFINIBAND_ISER=m
CONFIG_EDAC=y

#
# Reporting subsystems
#
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=m
CONFIG_EDAC_E752X=m
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
CONFIG_RTC_LIB=m
CONFIG_RTC_CLASS=m

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_DS1307=m
# CONFIG_RTC_DRV_DS1374 is not set
CONFIG_RTC_DRV_DS1672=m
# CONFIG_RTC_DRV_MAX6900 is not set
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=m
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF8563=m
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8581 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=m
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=m
CONFIG_RTC_DRV_DS1742=m
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
CONFIG_RTC_DRV_V3020=m

#
# on-CPU RTC drivers
#
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
CONFIG_ASUS_LAPTOP=m
# CONFIG_FUJITSU_LAPTOP is not set
CONFIG_MSI_LAPTOP=m
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_COMPAL_LAPTOP is not set
CONFIG_SONY_LAPTOP=m
# CONFIG_SONYPI_COMPAT is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ACPI_WMI is not set
CONFIG_ACPI_ASUS=m
CONFIG_ACPI_TOSHIBA=m

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
CONFIG_DMIID=y
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4_FS is not set
CONFIG_FS_XIP=y
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=m
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
CONFIG_JFS_FS=m
CONFIG_JFS_POSIX_ACL=y
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_FILE_LOCKING=y
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=m
CONFIG_GFS2_FS_LOCKING_DLM=m
CONFIG_OCFS2_FS=m
CONFIG_OCFS2_FS_O2CB=m
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m
CONFIG_OCFS2_FS_STATS=y
# CONFIG_OCFS2_DEBUG_MASKLOG is not set
# CONFIG_OCFS2_DEBUG_FS is not set
# CONFIG_OCFS2_FS_POSIX_ACL is not set
# CONFIG_BTRFS_FS is not set
CONFIG_DNOTIFY=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_AUTOFS_FS=m
CONFIG_AUTOFS4_FS=m
CONFIG_FUSE_FS=m
CONFIG_GENERIC_ACL=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
CONFIG_AFFS_FS=m
# CONFIG_ECRYPT_FS is not set
CONFIG_HFS_FS=m
CONFIG_HFSPLUS_FS=m
CONFIG_BEFS_FS=m
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=m
CONFIG_EFS_FS=m
CONFIG_CRAMFS=m
# CONFIG_SQUASHFS is not set
CONFIG_VXFS_FS=m
CONFIG_MINIX_FS=m
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
CONFIG_QNX4FS_FS=m
CONFIG_ROMFS_FS=m
CONFIG_SYSV_FS=m
CONFIG_UFS_FS=m
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=m
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_XPRT_RDMA=m
# CONFIG_SUNRPC_REGISTER_V4 is not set
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_RPCSEC_GSS_SPKM3=m
# CONFIG_SMB_FS is not set
CONFIG_CIFS=m
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
# CONFIG_CIFS_UPCALL is not set
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_EXPERIMENTAL is not set
CONFIG_NCP_FS=m
CONFIG_NCPFS_PACKET_SIGNING=y
CONFIG_NCPFS_IOCTL_LOCKING=y
CONFIG_NCPFS_STRONG=y
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
CONFIG_NCPFS_SMALLDOS=y
CONFIG_NCPFS_NLS=y
CONFIG_NCPFS_EXTRAS=y
CONFIG_CODA_FS=m
# CONFIG_AFS_FS is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_DETECT_SOFTLOCKUP is not set
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_RT_MUTEX_TESTER=y
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_TRACE_IRQFLAGS=y
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_LKDTM is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_SYSCTL_SYSCALL_CHECK=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_HW_BRANCH_TRACER=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_RING_BUFFER=y
CONFIG_TRACING=y

#
# Tracers
#
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SYSPROF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_BOOT_TRACER=y
# CONFIG_TRACE_BRANCH_PROFILING is not set
CONFIG_POWER_TRACER=y
CONFIG_STACK_TRACER=y
# CONFIG_HW_BRANCH_TRACER is not set
CONFIG_DYNAMIC_FTRACE=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DYNAMIC_PRINTK_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_NX_TEST is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_MMIOTRACE is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
# CONFIG_SECURITY_PATH is not set
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
# CONFIG_SECURITY_ROOTPLUG is not set
CONFIG_SECURITY_DEFAULT_MMAP_MIN_ADDR=0
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
CONFIG_SECURITY_SELINUX_DISABLE=y
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
# CONFIG_SECURITY_SMACK is not set
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
# CONFIG_CRYPTO_FIPS is not set
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=m
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=m
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_NULL=m
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_AUTHENC=m
# CONFIG_CRYPTO_TEST is not set

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
# CONFIG_CRYPTO_CTR is not set
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_PCBC=m
# CONFIG_CRYPTO_XTS is not set

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=m
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=m
CONFIG_CRYPTO_AES_X86_64=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
CONFIG_KVM_AMD=m
# CONFIG_KVM_TRACE is not set
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_FIND_LAST_BIT=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=m
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=m
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
This SF.net email is sponsored by:
SourcForge Community
SourceForge wants to tell your story.
http://p.sf.net/sfu/sf-spreadtheword
--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--bp/iNruPH9dso1Pn--
