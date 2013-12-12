From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] TCP: add option for silent port knocking with
 integrity protection
Date: Thu, 12 Dec 2013 02:23:17 +0100
Message-ID: <20131212012317.GL21717@two.firstfloor.org>
References: <52A75EF8.3010308@in.tum.de>
 <20131211.150137.368953964178408437.davem@davemloft.net>
 <52A8C8B4.4060109@in.tum.de>
 <20131211122637.75b09074@nehalam.linuxnetplumber.net>
 <87bo0nulkt.fsf@tassilo.jf.intel.com>
 <52A8ECF5.3070604@in.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org, jacob@appelbaum.net
To: Christian Grothoff <grothoff@in.tum.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52A8ECF5.3070604@in.tum.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> ... and then do the same for the first TCP packet with payload? And you

That gets passed through by the firewall rule.

> seriously would consider that "safer" or "less error prone", starting

Yes the risk of adding exploitable holes to the kernel is signficantly
lower.

-Andi
