From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity protection
Date: Wed, 11 Dec 2013 13:25:22 -0800
Message-ID: <87bo0nulkt.fsf@tassilo.jf.intel.com>
References: <52A75EF8.3010308@in.tum.de>
	<20131211.150137.368953964178408437.davem@davemloft.net>
	<52A8C8B4.4060109@in.tum.de>
	<20131211122637.75b09074@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christian Grothoff <grothoff@in.tum.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org, jacob@appelbaum.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131211122637.75b09074@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Wed, 11 Dec 2013 12:26:37 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <stephen@networkplumber.org> writes:
>
> The point is that doing it outside of TCP core is safer, less error prone
> and more flexible.

Or to put the question differently: what hooks would be needed to make
this efficiently work in user space?

It could be something like this: Firewall the port with forwarding the 
SYN packets using nfqueue, check for the SYN having the right magic,
change a firewall rule, re-inject using nfqueue (not fully sure how
well that works)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
