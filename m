From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 04 Dec 2014 10:19:11 +0100
Message-ID: <874mtbojqo.fsf@nemi.mork.no>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
	<B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com>
	<547D37CA.7050506@audiocodes.com>
	<alpine.LNX.2.03.1412020729470.1351@gmail.com>
	<547D5F84.6020608@audiocodes.com>
	<alpine.LNX.2.03.1412020747360.1921@gmail.com>
	<547D6D7B.5090704@audiocodes.com>
	<E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com>
	<547D7243.80508@audiocodes.com>
	<alpine.LNX.2.03.1412021130410.2697@gmail.com>
	<87fvcyqoup.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1412021410270.29633@gmail.com>
	<87lhmqp400.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1412021453340.7488@gmail.com>
	<1417532733483.89987@audiocodes.com>
	<alpine.LNX.2.03.1412021627360.8131@gmail.com>
	<547EA1D1.8010202@audiocodes.com>
	<alpine.LNX.2.03.1412030659001.1288@gmail.com>
	<547EA82F.5050500@audiocodes.com>
	<alpine.LNX.2.03.1412040730480.1320@gmail.com>
	<548020DD.3030705@audiocodes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Enrico Mioso <mrkiko.rs@gmail.com>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	Alex Strizhevsky <alexxst@gmail.com>,
	"Midge Shaojun Tan" <ShaojunMidge.Tan@audiocodes.com>,
	"youtux\@gmail.com" <youtux@gmail.com>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Kevin Zhu <Mingying.Zhu@audiocodes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53937 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752056AbaLDJTY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 04:19:24 -0500
In-Reply-To: <548020DD.3030705@audiocodes.com> (Kevin Zhu's message of "Thu, 4
	Dec 2014 08:52:49 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Zhu <Mingying.Zhu@audiocodes.com> writes:

> Guys,
>
> After rearranging the padding, putting NCM0 right after NTH, and disa=
ble
> ARP (FLAG_NOARP) and handling the offset alignment issue, it seems it
> begins to work, though there's still problem with DHCP.

Great!  But it would be good to know if _one_ of these changes is enoug=
h
to make it work.

> The DHCP packet's size becomes a large one after the TX function, whi=
ch
> is 16384, the maximum.

You can now (from v3.16) disable the padding by setting min_tx_pkt >=3D=
 tx_max.
Something like this should do for a simple test:

 echo 16384 >/sys/class/net/wwan0/cdc_ncm/min_tx_pkt


Bj=C3=B8rn
