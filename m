From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 03/15] batman-adv: add
	biggest_unsigned_int(x) macro
Date: Wed, 25 Apr 2012 14:09:04 -0400 (EDT)
Message-ID: <20120425.140904.935584797119761625.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6EF3@saturn3.aculab.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6EF4@saturn3.aculab.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6EF4-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Date: Wed, 25 Apr 2012 15:57:39 +0100

>  
>> > +/* Returns the biggest unsigned integer with the sizeof x */
>> > +#define biggest_unsigned_int(x) (~(x)0)
>> 
>> Nope - biggest_unsigned_int(unsigned char) is probably 0xffffffff
> 
> To correct myself, it is actually ((int)(-1)) (ie a signed value).

In any event this is just a terrible macro, and too stupid to live.
