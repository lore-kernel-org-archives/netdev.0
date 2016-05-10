From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V1 1/3] net: bulk alloc and reuse of SKBs in
 NAPI context
Date: Tue, 10 May 2016 11:29:47 +0200
Message-ID: <20160510112947.5a045d1a@redhat.com>
References: <20160509134352.3573.37044.stgit@firesoul>
	<20160509134429.3573.4048.stgit@firesoul>
	<CAKgT0Uftr643AR9n2=_aQmaGJO3eEyKTuaCfXwEKbYj1rVruRw@mail.gmail.com>
	<20160509215956.19ec1c10@redhat.com>
	<CAKgT0UfKzKWnNzGpB-915by2M1nzDAdNz-hDwwcwGoowmZefrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbcEJJ3w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 05:29:52 -0400
In-Reply-To: <CAKgT0UfKzKWnNzGpB-915by2M1nzDAdNz-hDwwcwGoowmZefrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 May 2016 13:46:32 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> > As you also know, tuning the SLUB system will give higher performance,
> > easily.  In the future, I'm planning to get some auto-tuning into the
> > SLUB allocator.  I've already discussed this with Christiph Lameter, at
> > MM-summit, see presentation[1] slides 4 and 5.  
> 
> We aren't discussing tuning parameters.  We are discussing this patch.
> If you want to argue that with certain tuning parameters this shows
> more performance then bring the numbers, but don't try to bias things.
> If you have to tune the system in some way that nobody will there is
> probably no point in submitting the patch because nobody will use it
> that way.

I think you missed the point. I didn't do parameter tuning for my
benchmarks. I hate tuning parameters, they are huge problem for users
of the kernel.
 My point is that I want to implement auto-tuning in the SLUB
allocator.  This network stack use-case, will just be one use-case
where the auto-tuning need to show improvements.  It is not that
complicated. FreeBSD have this kind of auto-tuning to the workload in
their slab implementation.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
