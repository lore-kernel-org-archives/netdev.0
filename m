From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 20:38:25 +0200
Message-ID: <m1zmut7l5q.fsf@muc.de>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>
	<20050517.104947.112621738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050517.104947.112621738.davem@davemloft.net> (David S.
 Miller's message of "Tue, 17 May 2005 10:49:47 -0700 (PDT)")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:

> From: Arthur Kepner <akepner@sgi.com>
> Date: Tue, 17 May 2005 09:18:26 -0700 (PDT)
>
>>   1) Fragments must arrive in order (or in reverse order) -
>>      out of order fragments are dropped. 
>
> Even the most simplistic flow over the real internet
> can get slight packet reordering.
>
> Heck, reordering happens on SMP on any network.
>
> IP is supposed to be resilient to side effects of network
> topology, and one such common side effect is packet reordering.
> It's common, it's fine, and the networking stack deals with it
> gracefully.  Strict reassembly does not.

If anything it would be better as a per route flag.
Then you could set it only for your local network
where you know Gigabit happens and reordering might
be avoidable in some cases.

-Andi

P.S.: Arthur I think your arguments would have more
force if you published the test program that demonstrates the
corruption.
