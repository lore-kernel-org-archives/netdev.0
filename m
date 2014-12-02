From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?
Date: Tue, 2 Dec 2014 07:49:45 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412020747360.1921@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
 <alpine.LNX.2.03.1411271932510.1548@gmail.com> <87ppc71xne.fsf@nemi.mork.no>,<alpine.LNX.2.03.1412012202480.1301@gmail.com> <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com> <547D37CA.7050506@audiocodes.com> <alpine.LNX.2.03.1412020729470.1351@gmail.com>
 <547D5F84.6020608@audiocodes.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1624549810-1417502991=:1921"
Cc: Eli Britstein <Eli.Britstein@audiocodes.com>,
	=?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Alex Strizhevsky <alexxst@gmail.com>,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	"youtux@gmail.com" <youtux@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kevin Zhu <Mingying.Zhu@audiocodes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:60783 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbaLBGtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 01:49:21 -0500
In-Reply-To: <547D5F84.6020608@audiocodes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1624549810-1417502991=:1921
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

Can you try to look at Windows registry keys based on the INF file as suggested 
or would this be a problem for you?
And... if you have any Huawei manutal talking about it: even device's 
^DSFLOWRPT
might be useful to some extent, but ... this is only just a note in case we 
don't find anything else.
Regards ... and good day to all of you,
Enrico


On Tue, 2 Dec 2014, Kevin Zhu wrote:

==Date: Tue, 2 Dec 2014 07:43:24
==From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: Eli Britstein <Eli.Britstein@audiocodes.com>, Bjørn Mork <bjorn@mork.no>,
==    Alex Strizhevsky <alexxst@gmail.com>,
==    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.com>,
==    "youtux@gmail.com" <youtux@gmail.com>,
==    "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
==    "netdev@vger.kernel.org" <netdev@vger.kernel.org>
==Subject: Re: Is this 32-bit NCM?
==
==I also tried to define CDC_NCM_DPT_DATAGRAMS_MAX as 1 to eliminate the
==paddings, but it did not work either, not even DHCP.
==
==Regards,
==Kevin
==
==On 12/02/2014 02:32 PM, Enrico Mioso wrote:
==> Hi again Eli,
==> Hi Kevin,
==> Hi everyone...
==>
==> As I understand it anyway - the distinction here tends not to be between
==> different types of packets.
==> It tends to be between received and sent packet.
==> We are not able to generate packets that the device retains valid.
==> If you manually configure the IP the device would have assigned you via DHCP,
==> your system will start answering ARP request, saying that the host with IP
==> aa.bb.cc.dd is at aa:bb:cc:dd:ee (using the MC address of the dongle).
==> However, the other host (gateway) will never know that. Indeed, it'll continue
==> asking who-is at aa.bb.cc.dd ?
==> At least, this is the situation I observed in the test system.
==>
==>
==> On Tue, 2 Dec 2014, Kevin Zhu wrote:
==>
==> ==Date: Tue, 2 Dec 2014 04:53:53
==> ==From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
==> ==To: Eli Britstein <Eli.Britstein@audiocodes.com>,
==> ==    Enrico Mioso <mrkiko.rs@gmail.com>
==> ==Cc: Bjørn Mork <bjorn@mork.no>, Alex Strizhevsky <alexxst@gmail.com>,
==> ==    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.com>,
==> ==    "youtux@gmail.com" <youtux@gmail.com>,
==> ==    "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
==> ==    "netdev@vger.kernel.org" <netdev@vger.kernel.org>
==> ==Subject: Re: Is this 32-bit NCM?
==> ==
==> ==Hi,
==> ==
==> ==The DHCP packets have the maximum size of dwNtbOutMaxSize=16384, while
==> ==the other packets are less than that. However, the DHCP queries are not
==> ==replied in time either, there's always some delay.
==> ==
==> ==By the way, though the device claims to support GET_MAX_DATAGRAM_SIZE,
==> ==but it returns error when the host sends this command to it. I disabled
==> ==this command in NCM driver and tried, but it's the same result.
==> ==
==> ==Regards,
==> ==Kevin
==> ==
==> ==On 12/02/2014 06:02 AM, Eli Britstein wrote:
==> ==> Hi Enrico and all,
==> ==>
==> ==> Maybe I missed something but what is the difference by the driver point of view between the dhcp discover and request (that are ok) to others (like arp, that is nok)?
==> ==> Maybe we can trace to compare them?
==> ==>
==> ==> Sent from my iPhone
==> ==>
==> ==>> On 1 בדצמ 2014, at 23:11, "Enrico Mioso" <mrkiko.rs@gmail.com> wrote:
==> ==>>
==> ==>> So ... I have two ideas left for now.
==> ==>> We know for sure the problem is in the way we TX frames, not the way we RX them
==> ==>> (the way we send, generate them, not the way we receive them).
==> ==>> Si I have two ideas, and I ask for help from the Linux-usb mailing list for
==> ==>> this first one.
==> ==>>
==> ==>> 1 - Does a wayexist to "replay" traffic crom a usb capture?
==> ==>> We might try to take the usb frames generated by Windows, and send them to the
==> ==>> device to see if there is any reaction. It should not be science fiction, I saw
==> ==>> them do that in the eciadsl old project.
==> ==>> 2 - The huawei ndis driver: does it work with these devices?
==> ==>> It should be a little bit out-dated now (at least in terms of dates, it might
==> ==>> work as well): the code is A LOT but, just in case, to see if there is any
==> ==>> chances it'll work. It remains to be seen in which kernels it can actually
==> ==>> compile again.
==> ==>>
==> ==>> If this works we might analyse what's happening and try to debug this out.
==> ==>> But I really would like this to work in the cdc_ncm driver + huawei_cdc_ncm.
==> ==>> Thank you.
==> ==This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
==> ==
==> ==If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
==> ==
==This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
==
==If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
==
--8323328-1624549810-1417502991=:1921--
