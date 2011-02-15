From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 27212] New: Warning kmemcheck: Caught 64-bit
 read from uninitialized memory in netlink_broadcast_filtered
Date: Tue, 15 Feb 2011 10:40:38 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1102151034400.10511@router.home>
References: <bug-27212-10286@https.bugzilla.kernel.org/> <20110120122549.85863a84.akpm@linux-foundation.org> <1295556085.2613.22.camel@edumazet-laptop> <4D393A99.9060104@kernel.org> <1297704922.2996.60.camel@edumazet-laptop>
 <AANLkTinKTdeO5mnE38n==aZMz5P1XKKM+kykhoBu0=9k@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Changli Gao <xiaosuo@gmail.com>,
	Vegard Nossum <vegardno@ifi.uio.no>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Rientjes <rientjes@google.com>
To: Pekka Enberg <penberg@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinKTdeO5mnE38n==aZMz5P1XKKM+kykhoBu0=9k@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2011, Pekka Enberg wrote:

> Looks good to me. Christoph, David, any objections to the patch?

My eyes hurt. Is there some way you could use tabs or spaces instead of
these weird symbols?

If the kmemcheck people are fine with checking data beyond the last byte
of the object then its fine with me.

Acked-by: Christoph Lameter <cl@linux.com>
