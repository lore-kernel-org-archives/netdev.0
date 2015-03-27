From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: Re: [PATCH 0/2 RESEND] IB/Verbs: Use helpers to refine the checking
 on transport and link layer
Date: Fri, 27 Mar 2015 17:03:14 +0100
Message-ID: <55157F42.1070303@profitbricks.com>
References: <5512CFB0.1050108@profitbricks.com> <1427378940.21101.100.camel@redhat.com> <55142DFD.2060100@profitbricks.com> <1427387258.21101.124.camel@redhat.com> <55143AAC.8040206@profitbricks.com> <20150326211334.GA3359@obsidianresearch.com> <5515284A.3030106@profitbricks.com> <20150327155530.GA21778@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Majd Dibbiny <majd@mellanox.c
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150327155530.GA21778-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 03/27/2015 04:55 PM, Jason Gunthorpe wrote:
> On Fri, Mar 27, 2015 at 10:52:10AM +0100, Michael Wang wrote:
>> [snip]
> So, in principle, testing the device should almost make sense. The
> device is the container for things like PD's MR's and QP's and those
> things can migrate between the ports freely, so all post must share
> the same attributes for those items.
>
> However.. AFAIK, we can have RoCEE and IB ports on the same device -
> which makes that whole concept seem sort of like nonsense..
>
> Anyhow, I would discourage testing the device. Each site has to be
> examined and determine if it working with a single port and really
> needs a port attribute (which may be a device attribute today) or if
> it is doing something device wide and is checking if all ports support
> X.
I prefer Doug's proposal that these attributes should be setup
by vendor at very beginning, unless the attributes keep changing...

>
>> Let's discuss and figure out the right name in the thread of
>> v2 patch set, I guess there will be a lot to be correct :-P
> Well, this is actually a hard job. This isn't a mechanical clean up,
> each site has to be inspected and understood before it can be
> migrated to the correct API.
I've send out the RFC patch set, let's see if it is possible to settle
some thing done ;-)

Regards,
Michael Wang

>
> Jason

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
