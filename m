From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 16:38:57 +0100
Message-ID: <cbb9e1113901f1a324359b6ed3f1a611@localhost>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
 <1298793252.8726.45.camel@edumazet-laptop>
 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
 <AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Albert Cahalan <acahalan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:33001 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754698Ab1B1Pi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 10:38:59 -0500
In-Reply-To: <AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 27 Feb 2011 18:33:39 -0500, Albert Cahalan wrote:



> I suppose there is a need to allow at least 2 packets despite any

> time limits, so that it remains possible to use a traditional modem

> even if a huge packet takes several seconds to send.



That is a good point! We talk about as we may know every use case of

Linux. But this is not true at all. One of my customer for example operates

the Linux network stack functionality on top of a proprietary MAC/Driver

where the current packet queue characteristic is just fine. The

time-drop-approach is unsuitable because the bandwidth can vary in a small

amount of time over a great range (0 till max. bandwidth). A sufficient

buffering shows up superior in this environment (only IPv{4,6}/UDP).



Hagen
