From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?
Date: Fri, 28 Nov 2014 09:39:09 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411280938001.4020@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com> <54781523.6030600@audiocodes.com>
 <alpine.LNX.2.03.1411280915310.3981@gmail.com> <547830EE.8060302@audiocodes.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1563606577-1417163950=:4020"
Cc: Alex Strizhevsky <alexxst@gmail.com>,
	=?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	"youtux@gmail.com" <youtux@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Britstein <Eli.Britstein@audiocodes.com>
To: Kevin Zhu <Mingying.Zhu@audiocodes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:40770 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbaK1Iil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 03:38:41 -0500
In-Reply-To: <547830EE.8060302@audiocodes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1563606577-1417163950=:4020
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

Bj-rn, you where right.
I was thinking this was the classic compulsory switch from a bitness to an 
higher one.
Sorry.


On Fri, 28 Nov 2014, Kevin Zhu wrote:

==Date: Fri, 28 Nov 2014 09:23:16
==From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: Alex Strizhevsky <alexxst@gmail.com>, Bjørn Mork <bjorn@mork.no>,
==    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.com>,
==    "youtux@gmail.com" <youtux@gmail.com>,
==    "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
==    "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
==    Eli Britstein <Eli.Britstein@audiocodes.com>
==Subject: Re: Is this 32-bit NCM?
==
==It's an ping packet. Windows pads it with 'abcdef...'.
==
==Regards,
==Kevin
==
==On 11/28/2014 04:17 PM, Enrico Mioso wrote:
==> And...why in Windows we have this line?
==> 0050   75 76 77 61 62 63 64 65 66 67 68 69 6e 63 6d 30  uvwabcdefghincm0
==> Is this just padding stuff before the "ncm0" string?
==> So in particular a simple line needs to be modified in practice in the driver,
==> or am I totally misguised?
==> Is our "offset" parameter calculatedsuitably in the driver? Looking at it, any
==> comment appreciated.
==>
==>
==> On Fri, 28 Nov 2014, Kevin Zhu wrote:
==>
==> ==Date: Fri, 28 Nov 2014 07:24:49
==> ==From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
==> ==To: Alex Strizhevsky <alexxst@gmail.com>, Bjørn Mork <bjorn@mork.no>,
==> ==    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.com>
==> ==Cc: Enrico Mioso <mrkiko.rs@gmail.com>, "youtux@gmail.com" <youtux@gmail.com>,
==> ==    "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
==> ==    "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
==> ==    Eli Britstein <Eli.Britstein@audiocodes.com>
==> ==Subject: Re: Is this 32-bit NCM?
==> ==
==> ==Hi all,
==> ==
==> ==I'm able to get the following prints with the original huawei_cdc_ncm driver
==> ==from Ubuntu 12.04.3. It keeps on printing. I'm also able to get an IP, but
==> ==no Internet access.
==> ==
==> ==^HCSQ:"WCDMA",64,59,55
==> ==
==> ==^DSFLOWRPT:0000000E,00000000,00000000,0000000000000000,0000000000000000,000
==> ==00000,00000000
==> ==
==> ==OK
==> ==
==> ==^NDISSTAT:1,,,"IPV4"
==> ==
==> ==^STIN: 1, 0, 0
==> ==
==> ==^DSFLOWRPT:00000010,00000000,00000000,0000000000000000,0000000000000000,000
==> ==00000,00000000
==> ==
==> ==^DSFLOWRPT:00000012,00000000,00000000,0000000000000000,0000000000000000,000
==> ==00000,00000000
==> ==
==> ==^DSFLOWRPT:00000014,00000000,00000000,0000000000000000,0000000000000000,000
==> ==00000,00000000
==> ==
==> ==^STIN: 1, 0, 0
==> ==
==> ==
==> ==...
==> ==^STIN: 1, 0, 0
==> ==
==> ==^DSFLOWRPT:0000008C,00000000,00000000,0000000000000B36,0000000000000000,000
==> ==00000,00000000
==> ==
==> ==^DSFLOWRPT:0000008E,00000000,00000000,0000000000000B36,0000000000000000,000
==> ==00000,00000000
==> ==
==> ==Regarding the alignment, I think we have some difference between Windows and
==> ==Linux. The spec says it should satisfy the following constraint.
==> ==
==> ==Offset % wNdpOutDivisor == wNdpOutPayloadRemainder (for OUT datagrams)
==> ==
==> ==It seems the Huawei device take the NDP offset (Ethernet Header Offset) as
==> ==the parameter 'Offset' in the above constraint. And in the Linux capture, it
==> ==does not comply with it.
==> ==
==> ==
==> ==dwNtbInMaxSize=131072 dwNtbOutMaxSize=16384 wNdpOutPayloadRemainder=2
==> ==wNdpOutDivisor=4 wNdpOutAlignment=4 wNtbOutMaxDatagrams=0 flags=0x1f
==> ==
==> ==Windows:
==> ==
==> ==0000   6e 63 6d 68 10 00 b6 00 7c 00 00 00 5c 00 00 00  ncmh....|...\...
==> ==0010   00 00 00 00 00 00 00 00 00 1e 10 1f 00 00 08 00  ................
==> ==0020   45 00 00 3c 00 9b 00 00 80 01 a0 fe 0a 71 a3 0e  E..<.........q..
==> ==0030   ca 6c 21 3c 08 00 4b 4b 00 01 02 10 61 62 63 64  .l!<..KK....abcd
==> ==0040   65 66 67 68 69 6a 6b 6c 6d 6e 6f 70 71 72 73 74  efghijklmnopqrst
==> ==0050   75 76 77 61 62 63 64 65 66 67 68 69 6e 63 6d 30  uvwabcdefghincm0
==> ==0060   20 00 00 00 00 00 00 00 00 00 00 00 12 00 00 00   ...............
==> ==0070   4a 00 00 00 00 00 00 00 00 00 00 00              J...........
==> ==
==> ==Linux: (thought it's a 16bit format capture, but it's the same as 32bit,
==> ==regarding the alignment)
==> ==
==> ==0000   4e 43 4d 48 0c 00 40 00 e2 00 0c 00 4e 43 4d 30  NCMH..@.....NCM0
==> ==0010   10 00 00 00 b8 00 2a 00 00 00 00 00 00 00 00 00  ......*.........
==> ==0020   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
==> ==0030   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
==> ==0040   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
==> ==0050   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
==> ==0060   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
==> ==0070   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
==> ==0080   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
==> ==0090   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
==> ==00a0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
==> ==00b0   00 00 00 00 00 00 00 00 ff ff ff ff ff ff 00 1e  ................
==> ==00c0   10 1f 00 00 08 06 00 01 08 00 06 04 00 01 00 1e  ................
==> ==00d0   10 1f 00 00 0a 71 cc a6 00 00 00 00 00 00 70 50  .....q........pP
==> ==00e0   f8 49                                            .I
==> ==
==> ==
==> ==Regards,
==> ==Kevin
==> ==On 11/27/2014 08:36 PM, Alex Strizhevsky wrote:
==> ==      Adding my colleagues - Eli, Kevin & Midge.
==> ==
==> ==Any ideas are welcome ;)
==> ==
==> ==
==> ==On Thu, Nov 27, 2014 at 12:03 PM, Bjørn Mork <bjorn@mork.no> wrote:
==> ==      Enrico Mioso <mrkiko.rs@gmail.com> writes:
==> ==
==> ==      > Ok - we can arrive to some ocnclusions regarding the
==> ==      E3272.
==> ==      > First of all - the modem seems buggy enough to not be
==> ==      able to handle requests
==> ==      > for different formats. You need to unplug and re-plug
==> ==      it, but this is onlyan
==> ==      > impression and is reasonable.
==> ==      >
==> ==      > Then - the modem will accept to ndisdup the connection
==> ==      with
==> ==      > at^ndisdup=1,1,"internet"
==> ==      > but - if we use huawei_cdc_ncm + cdc_ncm we have no flow
==> ==      handling messages and
==> ==      > the modem stops here.
==> ==      > If we use the cdc_ncm 32-bit driver (modified) we get
==> ==      lotfs of
==> ==      > ^dsflorpt
==> ==      > that's how it should be.
==> ==      > So I think we can say that something is changing.
==> ==      > Then there's the alignment problem you mentioned in your
==> ==      previous reply. And
==> ==      > this is hard to solve.
==> ==      > could you try to help me understand where the problem
==> ==      is?
==> ==      > I feel like we are very close to the solution but
==> ==      something isn't working.
==> ==      > Or might be just try to change the 16 bit driver?
==> ==
==> ==If you use a recent version of the driver as a basis, then you
==> ==get the
==> ==CDC NCM NTB parameters in sysfs (if not, then you need to enable
==> ==debugging and look in the log for these values).  For example:
==> ==
==> ==bjorn@nemi:~$ grep . /sys/class/net/wwan0/cdc_ncm/*
==> ==/sys/class/net/wwan0/cdc_ncm/bmNtbFormatsSupported:0x0001
==> ==/sys/class/net/wwan0/cdc_ncm/dwNtbInMaxSize:15360
==> ==/sys/class/net/wwan0/cdc_ncm/dwNtbOutMaxSize:15360
==> ==/sys/class/net/wwan0/cdc_ncm/min_tx_pkt:13824
==> ==/sys/class/net/wwan0/cdc_ncm/rx_max:15360
==> ==/sys/class/net/wwan0/cdc_ncm/tx_max:15360
==> ==/sys/class/net/wwan0/cdc_ncm/tx_timer_usecs:400
==> ==/sys/class/net/wwan0/cdc_ncm/wNdpInAlignment:4
==> ==/sys/class/net/wwan0/cdc_ncm/wNdpInDivisor:1
==> ==/sys/class/net/wwan0/cdc_ncm/wNdpInPayloadRemainder:0
==> ==/sys/class/net/wwan0/cdc_ncm/wNdpOutAlignment:4
==> ==/sys/class/net/wwan0/cdc_ncm/wNdpOutDivisor:32
==> ==/sys/class/net/wwan0/cdc_ncm/wNdpOutPayloadRemainder:0
==> ==/sys/class/net/wwan0/cdc_ncm/wNtbOutMaxDatagrams:32
==> ==
==> ==
==> ==The possible problem I am thinking of is proper handling of the
==> ==wNdp*PayloadRemainder values. See section 3.3.4 "NCM Ethernet
==> ==Frame
==> ==Alignment" in the spec.  Which is confusing as hell, but if I
==> ==understand
==> ==it correctly then we are supposed to align the start of the IP
==> ==packets
==> ==(the "payload", _not_ the ethernet frame) to a whole
==> ==wNdp*Divisor number
==> ==as long as the wNdp*PayloadRemainder is 0.
==> ==
==> ==
==> ==Bjørn
==> ==
==> ==
==> ==
==> ==This email and any files transmitted with it are confidential material. They
==> ==are intended solely for the use of the designated individual or entity to
==> ==whom they are addressed. If the reader of this message is not the intended
==> ==recipient, you are hereby notified that any dissemination, use, distribution
==> ==or copying of this communication is strictly prohibited and may be unlawful.
==> ==
==> ==If you have received this email in error please immediately notify the
==> ==sender and delete or destroy any copy of this message
==> ==
==This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
==
==If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
==
--8323328-1563606577-1417163950=:4020--
