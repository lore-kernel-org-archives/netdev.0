From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity protection
Date: Fri, 13 Dec 2013 04:07:11 +0100
Message-ID: <20131213030711.GA30876@order.stressinduktion.org>
References: <20131211.150137.368953964178408437.davem@davemloft.net> <52A8C8B4.4060109@in.tum.de> <20131211122637.75b09074@nehalam.linuxnetplumber.net> <87bo0nulkt.fsf@tassilo.jf.intel.com> <52A8ECF5.3070604@in.tum.de> <20131212012317.GL21717@two.firstfloor.org> <52A98DBF.4090702@appelbaum.net> <52A9A17F.6050505@in.tum.de> <1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com> <20131212154637.GG4675@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Christian Grothoff <grothoff@in.tum.de>,
	Jacob Appelbaum <jacob@appelbaum.net>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131212154637.GG4675@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 12, 2013 at 04:46:37PM +0100, Hannes Frederic Sowa wrote:
> On Thu, Dec 12, 2013 at 06:34:24AM -0800, Eric Dumazet wrote:
> > With various proposals (like TCP minion), maybe its time to be able to
> > implement part of TCP stack in user land (Keep the mux inside the
> > kernel, and forward raw incoming packets to user land where all the
> > crazy things can be done without kernel patching.)
> 
> Maybe this knocking scheme is implementable with a socket filter and we could
> add a switch to tweak drop behaviour.

Just fyi, maybe it is useful. I haven't tested it:

For the sending side one could craft the handshake by hand (raw/packet
sockets) and splice in an already established socket via tcp connection
repair.
