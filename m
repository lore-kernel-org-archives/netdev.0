From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 26 May 2008 16:29:04 +0200
Message-ID: <20080526142904.GA11829@elte.hu>
References: <20080526115628.GA31316@elte.hu> <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi> <20080526135940.GB24870@elte.hu> <20080526141252.GA31352@elte.hu> <20080526141713.GA5771@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:58018 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754873AbYEZO3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 10:29:34 -0400
Content-Disposition: inline
In-Reply-To: <20080526141713.GA5771@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


there's TCP ACK activity every 120 seconds:

 16:19:05.260000 IP europe.37198 > europe.distcc: . ack 2022529163 win 257
  <nop,nop,timestamp 233526 221526>
 16:19:05.260000 IP europe.distcc > europe.37198: . ack 1          win 0 
  <nop,nop,timestamp 233526 7020>
 16:21:05.260000 IP europe.37198 > europe.distcc: . ack 1          win 257
  <nop,nop,timestamp 245526 233526>
 16:21:05.260000 IP europe.distcc > europe.37198: . ack 1          win 0
  <nop,nop,timestamp 245526 7020>
 16:23:05.260000 IP europe.37198 > europe.distcc: . ack 1          win 257
  <nop,nop,timestamp 257526 245526>
 16:23:05.260000 IP europe.distcc > europe.37198: . ack 1          win 0
  <nop,nop,timestamp 257526 7020>
 16:25:05.260000 IP europe.37198 > europe.distcc: . ack 1          win 257 
  <nop,nop,timestamp 269526 257526>
 16:25:05.260000 IP europe.distcc > europe.37198: . ack 1          win 0 
  <nop,nop,timestamp 269526 7020>
 16:27:05.260000 IP europe.37198 > europe.distcc: . ack 1          win 257 
  <nop,nop,timestamp 281526 269526>
 16:27:05.260000 IP europe.distcc > europe.37198: . ack 1          win 0 
  <nop,nop,timestamp 281526 7020>

The socket on the other side of the localhost connection, 
10.0.1.15:3632, produces no packets.

a detail i forgot to mention: i reproduced the same TCP hang on a 32-bit 
system and on a 64-bit system as well.

	Ingo
