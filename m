From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC PATCH 1/3] lib: adding an Array-based Lock-Free (ALF)
 queue
Date: Thu, 11 Dec 2014 14:15:38 -0500 (EST)
Message-ID: <20141211.141538.912268168491944997.davem@davemloft.net>
References: <20141210141332.31779.56391.stgit@dragon>
	<20141210141512.31779.96487.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org,
	paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org
To: brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141210141512.31779.96487.stgit@dragon>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 10 Dec 2014 15:15:26 +0100

> +static inline int
> +alf_mp_enqueue(const u32 n;
> +	       struct alf_queue *q, void *ptr[n], const u32 n)
> +{
 ...
> +/* Main Multi-Consumer DEQUEUE */
> +static inline int
> +alf_mc_dequeue(const u32 n;
> +	       struct alf_queue *q, void *ptr[n], const u32 n)
> +{

I would seriously consider not inlining these.
