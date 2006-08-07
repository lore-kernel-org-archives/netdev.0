From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3: tg3_stop_block timed out
Date: Mon, 07 Aug 2006 16:07:43 -0700
Message-ID: <1154992063.5328.3.camel@rh4>
References: <eb8fmt$6lf$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23556 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751140AbWHGXGj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:06:39 -0400
To: "Bernd Schubert" <bernd-schubert@gmx.de>
In-Reply-To: <eb8fmt$6lf$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 00:43 +0200, Bernd Schubert wrote:
> Hi,
> 
> I have seen a few reports like this, but now broadcom seems to actively
> support tg3, so I decided to send this.
> 
> ... [many hamilton not responding messages]
> 4554928.798000] nfs: server hamilton not responding, still trying
> [4554935.319000] nfs: server hamilton not responding, still trying
> [4555468.940000] NETDEV WATCHDOG: eth1: transmit timed out
> [4555468.940000] tg3: eth1: transmit timed out, resetting
> [4555469.044000] tg3: tg3_stop_block timed out, ofs=3400 enable_bit=2
> [4555469.147000] tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
> [4555469.251000] tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
> [4555469.354000] tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
> [4555469.433000] tg3: eth1: Link is down.
> [4555472.593000] tg3: eth1: Link is up at 1000 Mbps, full duplex.
> [4555472.594000] tg3: eth1: Flow control is on for TX and on for RX.
> [4555498.016000] nfs: server 129.206.21.200 OK
> [4555648.015000] nfs: server 129.206.21.200 OK
> ... [many ok messages]
> 
I need to know what hardware you're using so please send me the tg3
probing output for eth1 when you load the driver. Do you have TSO
enabled?

