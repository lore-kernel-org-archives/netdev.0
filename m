From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Wed, 5 Aug 2015 22:53:35 -0600
Message-ID: <20150806045335.GC14960@obsidianresearch.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
 <CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
 <55BB6F10.5030408@redhat.com>
 <20150731163201.GA6027@obsidianresearch.com>
 <55BBB353.7020806@redhat.com>
 <CAJ3xEMiP57qf58B=VHRazs50RC5r-7OsUPb=GV1kBQ6vu6Tqjw@mail.gmail.com>
 <20150731220102.GA31209@obsidianresearch.com>
 <CAJ3xEMjgvgvc8WyUhHagiH4gNs6KK7pL_TmhXCywNiWEy4p70w@mail.gmail.com>
 <55BDCD36.6000301@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Somnath Kotur <Somnath.Kotur-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <55BDCD36.6000301-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 02, 2015 at 10:56:38AM +0300, Matan Barak wrote:

> Indeed this design flaw was introduced when the first legacy verb was
> extended. I think that falling back from extended code to legacy code
> should be in the uverbs code. ib_uverbs_write will return -ENOSYS only
> if both extended and non-extended don't exist. The uverbs command itself
> will call the non-extended form if the comp_mask is zero and all
> data between legacy size and the given size are zero as well.
> What do you think?

Yes, that is what I had expected from day 1.. Didn't notice it in the
first introduction.

Thanks,
Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
