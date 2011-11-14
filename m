From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH] net/packet: remove dead code and unneeded variable from prb_setup_retire_blk_timer()
Date: Mon, 14 Nov 2011 10:54:01 -0500
Message-ID: <CAAsGZS7sPYqXi+KxjD9omzvDME6A3SFGv+kMadMhJk6qNtSsBw@mail.gmail.com>
References: <alpine.LNX.2.00.1111132247440.3368@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	waltje@uwalt.nl.mugnet.org, gw4pts@gw4pts.ampr.org,
	waltje@linux.com, ross.biro@gmail.com, alan@linux.intel.com
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1111132247440.3368@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 13, 2011 at 4:55 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> We test for 'tx_ring' being != zero and BUG() if that's the case. So after
> that check there is no way that 'tx_ring' could be anything _but_ zero, so
> testing it again is just dead code. Once that dead code is removed, the
> 'pkc' local variable becomes entirely redundant, so remove that as well.

It was there so that it would be a no-brainer thing for the next
person who would want to enable tx_ring support. And given that this
check was called just once during the initial setup, it didn't seem
like a big deal to me. And the BUG() would let the next-person know
what different paths need to be plugged.


Chetan Loke
