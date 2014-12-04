From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 04 Dec 2014 10:55:06 +0100
Message-ID: <87mw73n3id.fsf@nemi.mork.no>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
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
	<548020DD.3030705@audiocodes.com> <874mtbojqo.fsf@nemi.mork.no>
	<548028A0.5000909@audiocodes.com>
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
Received: from canardo.mork.no ([148.122.252.1]:54895 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086AbaLDJzT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 04:55:19 -0500
In-Reply-To: <548028A0.5000909@audiocodes.com> (Kevin Zhu's message of "Thu, 4
	Dec 2014 09:26:20 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Zhu <Mingying.Zhu@audiocodes.com> writes:

> I will find it out. And I don't have v3.16 and I'm not going to upgra=
de
> my OS to that. Sorry. So I would just stick to v3.13.

Ouch.  well, OK.  I certainly hope you are at v3.13.10 or newer at
least.  Otherwise we know very well what the problem is...

One of the reasons for the series that went into v3.16 was making this
sort of debugging easier, enabling on-the-fly NCM aggregation parameter
tuning.  I'd certainly recommend taking advantage of it instead of
rebulding the driver every time you want to test the effect of some
minor change to the aggregation scheme.  And do feel free to add more
knobs if you need them.


Bj=C3=B8rn
