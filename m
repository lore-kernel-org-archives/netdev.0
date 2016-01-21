From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Thu, 21 Jan 2016 11:21:39 -0800 (PST)
Message-ID: <20160121.112139.865122294942281441.davem@davemloft.net>
References: <56A10FEC.5020402@mellanox.com>
	<20160121182420.GA51708@flatif-MOBL1>
	<CAJ3xEMgE1-EuNBmYVfLoBwjohcxt5tio6wtZn=TYvDAgQgh9cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMgE1-EuNBmYVfLoBwjohcxt5tio6wtZn=TYvDAgQgh9cw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 21 Jan 2016 20:40:53 +0200

> On Thu, Jan 21, 2016 at 8:24 PM, Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> 
>> We can certainly take up the discussion on improving the current port mapper design/implementation. But
>> that would be more appropriate in a separate thread.
> 
> If we observe a kernel API / mechanism which could be wrongly
> duplicated between two drivers, and now a new driver comes to town
> with C&P-ing this -- why not stopping and thinking before rushing to
> get the 3rd duplication upstream?

Yes, this really looks like a huge disaster.

People have to stop doing unique APIs in their drivers, especially
when equivalent functionality exists generically.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
