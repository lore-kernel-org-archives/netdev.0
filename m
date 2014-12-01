From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?
Date: Mon, 1 Dec 2014 06:28:05 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412010626590.1576@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com> <54781523.6030600@audiocodes.com>
 <alpine.LNX.2.03.1411280923230.3997@gmail.com> <54783443.50700@audiocodes.com> <alpine.LNX.2.03.1411280944200.4040@gmail.com> <54783A1D.3090607@audiocodes.com> <alpine.LNX.2.03.1411281014450.4101@gmail.com> <54783F84.20105@audiocodes.com>
 <alpine.LNX.2.03.1411300202310.4742@gmail.com> <CAPChA0czA3vxPZdwk-SgO1Wr83zOV1UoWcL4=05qtBktwq5=TA@mail.gmail.com> <alpine.LNX.2.03.1411301139290.1972@gmail.com> <547BDCF5.8070705@audiocodes.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1847173585-1417411686=:1576"
Cc: Alex Strizhevsky <alexxst@gmail.com>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"youtux@gmail.com" <youtux@gmail.com>,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: Kevin Zhu <Mingying.Zhu@audiocodes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:50896 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbaLAF1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 00:27:36 -0500
In-Reply-To: <547BDCF5.8070705@audiocodes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1847173585-1417411686=:1576
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

Sorry.
I am a visually impaired person - and use a braille display to read your 
messages; can't have access to files that don't contain ascii-based content.
Sorry Kevin.

And thank you for everything. Don't worry about the lateness.
It was sunday.


On Mon, 1 Dec 2014, Kevin Zhu wrote:

==Date: Mon, 1 Dec 2014 04:14:10
==From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
==To: Enrico Mioso <mrkiko.rs@gmail.com>, Alex Strizhevsky <alexxst@gmail.com>
==Cc: Eli Britstein <Eli.Britstein@audiocodes.com>,
==    "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
==    "youtux@gmail.com" <youtux@gmail.com>,
==    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.com>,
==    "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
==    Bjørn Mork <bjorn@mork.no>
==Subject: Re: Is this 32-bit NCM?
==
==Hi Enrico,
==
==I think those packets are some interrupt status. Please check my capture by
==wireshark.
==
==[IMAGE]
==
==And this is a ping packet from window, which indicates it's an NCM packet.
==
==[IMAGE]
==
==Regards,
==Kevin
==On 11/30/2014 06:39 PM, Enrico Mioso wrote:
==
==My impression guys is that this is not cdc_ncm protocol.
==Look how many short packets you can see in there.
==Without any ncm signature.
==right?
==
==
==On Sun, 30 Nov 2014, Alex Strizhevsky wrote:
==
====Date: Sun, 30 Nov 2014 05:22:20
====From: Alex Strizhevsky <alexxst@gmail.com>
====To: Mrkiko Rs <mrkiko.rs@gmail.com>
====Cc: Eli Britstein <Eli.Britstein@audiocodes.com>, linux-usb@vger.kernel.or
==g,
====    "youtux@gmail.com" <youtux@gmail.com>,
====    Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
====    "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
====    Kevin Zhu <Mingying.Zhu@audiocodes.com>, Bjørn Mork <bjorn@mork.no>
====Subject: Re: Is this 32-bit NCM?
====
====
====Hi Enrico,
====
====Actually I have two dongles with different firmwares (23.128.00.00.00 &
====21.286.03.01.209).
====Probably have sent to you the USB  capture with the first one.
====
====In fact we have to make work the second one, this dongle has relevant SW.
====
====On Nov 30, 2014 3:13 AM, "Enrico Mioso" <mrkiko.rs@gmail.com> wrote:
====      Hi guys.
====      Sorry for the late our but ... I was trying to figure out
====      something new about
====      this dongle.
====      I also searched for it in my city shops without finding it
====      actually.
====      But then I came back and ... tried to look at some things.
====
====      Alex, Kevin: in the Windows USB captures you sent me (and that I
====      sent on the
====      List), I can notiche something very strange.
====      with a shell on a computer connected to a test device I can see
====      the following:
====      at+gmr
====      21.286.03.01.209
====      OK
====      and so why in the Windows sniff the dongle answers to the same
====      question
====      something like
====      23.128.00.00.00
====      ?
====      Alex - was it the same dongle?
====      Kevin or anyone: can you use putty to interact with the dongle
====      under Windows
====      and type some commands, like:
====      at+gmr
====      and other similar commands?
====      If the dongle reports different firmware versions under Linux
====      and Windows, then
====      guys... we need to figure out the Windows switch message.
====      Overmore - in the device installation sh*t, you can see there is
====      a firmware
====      updater... Why?
====
====      Alex: I used the
====      at^reset
====      command to get the modem back to normal state once; and so it
====      restored the
====      nvram to default or something.
====      If you reconnect it to windows ... i hope it gets re-setup as
====      before.
====      But - nothing harmful to the device, only to it's settings,
====      sorry.
====      I restored the relevant settings and it connects again, but no
====      dhcp. But - be
====      peaceful: other modems out there seems to not get dhcp anyway.
====      this is the state the modem arrives when you buy it, so windows
====      should know
====      Wwhat To Say To The Modem (TM).
====      Another thing - note that:
====      [14170.048693] cdc_ncm 1-2:1.2: GET_MAX_DATAGRAM_SIZE failed
====
====      Any ideas, comments, suggestions are highly appreciated guys.
====      Of any type.
====
====      Bjorn - unfortunately it seems this problem is related to E3727
====      and E3276
====      sticks; they can get IP from DHCP but not go ahead.
====
====
====
==
==
==This email and any files transmitted with it are confidential material. They
==are intended solely for the use of the designated individual or entity to
==whom they are addressed. If the reader of this message is not the intended
==recipient, you are hereby notified that any dissemination, use, distribution
==or copying of this communication is strictly prohibited and may be unlawful.
==
==If you have received this email in error please immediately notify the
==sender and delete or destroy any copy of this message
==
--8323328-1847173585-1417411686=:1576--
