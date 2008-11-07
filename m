From: David Miller <davem@davemloft.net>
Subject: Re: time for TCP ECN defaulting to on?
Date: Thu, 06 Nov 2008 20:49:29 -0800 (PST)
Message-ID: <20081106.204929.161401868.davem@davemloft.net>
References: <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
	<20081105.151015.206163697.davem@davemloft.net>
	<alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.blueman@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
To: swmike@swm.pp.se
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mikael Abrahamsson <swmike@swm.pp.se>
Date: Fri, 7 Nov 2008 05:46:28 +0100 (CET)

> I see that in
> <http://www.icir.org/floyd/papers/draft-ietf-tsvwg-tcp-ecn-00.txt>
> there is a recommendation to not use ECN on retransmits, is there
> code right now (or planned) to do some kind of "ECN blackhole
> detection", ie if no response is received to SYN with ECN set,
> continue by sending the second SYN without ECN and keep this
> information for the duration of the TCP session?

No, we are firmly against any form of ECN blackhole detection.  Alexey Kuznetsov and
Sally Floyd argued this out exhaustively several years ago.
