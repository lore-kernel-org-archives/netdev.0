From: David Miller <davem@davemloft.net>
Subject: Re: [net/mm PATCH v2 0/3] Page fragment updates
Date: Tue, 27 Dec 2016 13:55:28 -0500 (EST)
Message-ID: <20161227.135528.1940863604492112350.davem@davemloft.net>
References: <20161223170756.14573.74139.stgit@localhost.localdomain>
	<20161223.125053.1340469257610308679.davem@davemloft.net>
	<CAKgT0UeP3QkjPQcPGv4ONhO5D56-+TL=-JYx6R+YJvLcCgK3cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: alexander.duyck@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAKgT0UeP3QkjPQcPGv4ONhO5D56-+TL=-JYx6R+YJvLcCgK3cw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 27 Dec 2016 10:54:14 -0800

> Dave, I was wondering if you would be okay with me trying to push the
> three patches though net-next.  I'm thinking I might scale back the
> first patch so that it is just a rename instead of making any
> functional changes.  The main reason why I am thinking of trying to
> submit through net-next is because then I can then start working on
> submitting the driver patches for net-next.  Otherwise I'm looking at
> this set creating a merge mess since I don't see a good way to push
> the driver changes without already having these changes present.
> 
> I'll wait until Andrew can weigh in on the patches before
> resubmitting.  My thought was to get an Acked-by from him and then see
> if I can get them accepted into net-next.  That way there isn't any
> funky cross-tree merging that will need to go on, and it shouldn't
> really impact the mm tree all that much as the only consumers for the
> page frag code are the network stack anyway.

I'm fine with this plan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
