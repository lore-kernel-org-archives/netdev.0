From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?
Date: Wed, 3 Dec 2014 07:00:19 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412030659001.1288@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com> <alpine.LNX.2.03.1411271932510.1548@gmail.com> <87ppc71xne.fsf@nemi.mork.no>
 <alpine.LNX.2.03.1412012202480.1301@gmail.com> <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com> <547D37CA.7050506@audiocodes.com> <alpine.LNX.2.03.1412020729470.1351@gmail.com> <547D5F84.6020608@audiocodes.com> <alpine.LNX.2.03.1412020747360.1921@gmail.com>
 <547D6D7B.5090704@audiocodes.com> <E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com> <547D7243.80508@audiocodes.com> <alpine.LNX.2.03.1412021130410.2697@gmail.com> <87fvcyqoup.fsf@nemi.mork.no> <alpine.LNX.2.03.1412021410270.29633@gmail.com>
 <87lhmqp400.fsf@nemi.mork.no>,<alpine.LNX.2.03.1412021453340.7488@gmail.com> <1417532733483.89987@audiocodes.com> <alpine.LNX.2.03.1412021627360.8131@gmail.com> <547EA1D1.8010202@audiocodes.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-816276584-1417586420=:1288"
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	Alex Strizhevsky <alexxst@gmail.com>,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	"youtux@gmail.com" <youtux@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kevin Zhu <Mingying.Zhu@audiocodes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:41953 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaLCF7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 00:59:48 -0500
In-Reply-To: <547EA1D1.8010202@audiocodes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-816276584-1417586420=:1288
Content-Type: TEXT/PLAIN; charset=Windows-1252
Content-Transfer-Encoding: 8BIT

Yes - I think this would be ok. You might try this with the 16-bit river first, 
and then with the 32-bit one to see how things work.
I hope for the best.
Let us all know,
Enrico


On Wed, 3 Dec 2014, Kevin Zhu wrote:

==Date: Wed, 3 Dec 2014 06:38:27
==From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: Bjørn Mork <bjorn@mork.no>, Eli Britstein <Eli.Britstein@audiocodes.com>,
==    Alex Strizhevsky <alexxst@gmail.com>,
==    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.com>,
==    "youtux@gmail.com" <youtux@gmail.com>,
==    "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
==    "netdev@vger.kernel.org" <netdev@vger.kernel.org>
==Subject: Re: Is this 32-bit NCM?
==
==My dongle also works with the huawei driver. I think only the 32bit
==format and NDP location matter. We may modify the TX function to put NTH
==and NDP at the beginning of a NTB and see if it will work with the
==driver cdc_ncm.
==
==Regards,
==Kevin
==
==On 12/02/2014 11:28 PM, Enrico Mioso wrote:
==> ... And what do you think about the source code of their ndis driver?
==> We at least know now the device work with it, so we have something to mimic :D
==> thank you for your work and patience Kevin.
==>
==> On Tue, 2 Dec 2014, Kevin Zhu wrote:
==>
==> ==Date: Tue, 2 Dec 2014 16:04:25
==> ==From: Kevin Zhu <Mingying.Zhu@audiocodes.com>
==> ==To: Enrico Mioso <mrkiko.rs@gmail.com>, Bjørn Mork <bjorn@mork.no>
==> ==Cc: Eli Britstein <Eli.Britstein@audiocodes.com>,
==> ==    Alex Strizhevsky <alexxst@gmail.com>,
==> ==    Midge Shaojun  Tan <ShaojunMidge.Tan@audiocodes.com>,
==> ==    "youtux@gmail.com" <youtux@gmail.com>,
==> ==    "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
==> ==    "netdev@vger.kernel.org" <netdev@vger.kernel.org>
==> ==Subject: Re: Is this 32-bit NCM?
==> ==
==> ==I do not understand why the wSequence matters. By the way, I think I see some NDPs are right after NTH headers in the windows capture.
==> ==
==> ==________________________________________
==> ==From: Enrico Mioso <mrkiko.rs@gmail.com>
==> ==Sent: Tuesday, December 2, 2014 21:53
==> ==To: Bjørn Mork
==> ==Cc: Kevin Zhu; Eli Britstein; Alex Strizhevsky; Midge Shaojun  Tan; youtux@gmail.com; linux-usb@vger.kernel.org; netdev@vger.kernel.org
==> ==Subject: Re: Is this 32-bit NCM?
==> ==
==> ==Thank you very much Bjorn.
==> ==
==> ==
==> ==On Tue, 2 Dec 2014, Bjørn Mork wrote:
==> ==
==> ====Date: Tue, 2 Dec 2014 14:37:03
==> ====From: Bjørn Mork <bjorn@mork.no>
==> ====To: Enrico Mioso <mrkiko.rs@gmail.com>
==> ====Cc: Kevin Zhu <Mingying.Zhu@audiocodes.com>,
==> ====    Eli Britstein <Eli.Britstein@audiocodes.com>,
==> ====    Alex Strizhevsky <alexxst@gmail.com>,
==> ====    Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
==> ====    "youtux@gmail.com" <youtux@gmail.com>,
==> ====    "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
==> ====    "netdev@vger.kernel.org" <netdev@vger.kernel.org>
==> ====Subject: Re: Is this 32-bit NCM?
==> ====
==> ====Enrico Mioso <mrkiko.rs@gmail.com> writes:
==> ====
==> ====> ... but out of curiosity: are NCM specs allowing to change order of things in
==> ====> the package or not?
==> ====> This is not to start philosofical falames or something, but to understand
==> ====> better how things work. And, if they do: how much arbitrarily?
==> ====
==> ====Only the NTB header has a fixed location. The rest can be anywhere and
==> ====in any order. Quoting from section 3 Data Transport:
==> ====
==> ====  "Within any given NTB, the NTH always must be first; but the other
==> ====   items may occur in arbitrary order."
==> ====
==> ====
==> ====Bjørn
==> ====
==> ==This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
==> ==
==> ==If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
==> ==
==This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
==
==If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
==
--8323328-816276584-1417586420=:1288--
