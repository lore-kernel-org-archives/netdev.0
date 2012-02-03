From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: RE: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Fri, 03 Feb 2012 21:55:51 +0100
Message-ID: <6e2d275588a21cad8c267699c5231c44@localhost>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
 <02e98f84ee62073e1bf92338f6744fde@localhost>
 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA3E@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<nhorman@tuxdriver.com>, <tgraf@infradead.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	<eric.dumazet@gmail.com>, Seiji Aguchi <seiji.aguchi@hds.com>
To: Satoru Moriya <satoru.moriya@hds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:54496 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757745Ab2BCUzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 15:55:53 -0500
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA3E@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 3 Feb 2012 15:43:30 -0500, Satoru Moriya wrote:



> Actually, we've already used systemtap in our flight recorder.

> But we believe that tcp retransmission is one of the fundamental

> function in tcp stack and so kernel itself should provide the

> instruments from which we can get enough information without

> tools which is not included in kernel.



Mhh, that's no real reason to add tracepoints all over. There where some

lengthy debates on lkml about inflationary use of tracepoints. Especially

this case where systemtap can provide the same information (btw: for

tracepoints you may also need some userspace tools). Maybe you should start

to improve systemtap. ;) But hey, it is David who decides if he is fine

with your patch.



Hagen
