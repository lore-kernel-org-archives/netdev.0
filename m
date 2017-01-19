From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Thu, 19 Jan 2017 11:03:08 -0700
Message-ID: <20170119180308.GD8109@obsidianresearch.com>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
 <20170118173327.GF32481@mtr-leonro.local>
 <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
 <20170118183127.GC14198@obsidianresearch.com>
 <5f90fd26-e7bf-bb2a-01f2-6b166f2265e9@sandisk.com>
 <20170119063326.GJ32481@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Ariel Almog <arielalmogworkemails-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170119063326.GJ32481-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2017 at 08:33:26AM +0200, Leon Romanovsky wrote:
> On Wed, Jan 18, 2017 at 01:45:14PM -0800, Bart Van Assche wrote:
> > On 01/18/2017 10:31 AM, Jason Gunthorpe wrote:
> > > I think it depends on what this tool is supposed to cover, but based
> > > on the description, I would start with netlink-only.
> > >
> > > The only place verbs covers a similar ground is in 'device
> > > capabilities' - for some of that you might want to open a new-uAPI
> > > verbs fd, but even the capability data from that would not be
> > > totally offensive to be accessed over netlink.
> > >
> > > IMHO netlink should cover almost everything found in sysfs today.
> >
> > We would need a very strong argument to introduce a netlink API that
> > duplicates existing sysfs API functionality. Since the sysfs API is
> > extensible, why not extend that API further? E.g. the SCST sysfs API
> > shows that more is possible with sysfs than what most kernel drivers
> > realize.
> 
> We didn't look deeply on sysfs mainly because it is unpopular
> in netdev community. Maybe we were misled and it is simply not true.

sysfs is unpopular because the 'one value per file' dogma is laregly
unsuitable for complex mulit-value atomic changes which are common in
netdev. You can force it to work, but it is pretty horrible..

It is also very expensive if you want to shuttle a lot of data, eg I
could not see doing something like 'netstat' for IB through sysfs

Maybe you should start by showing some examples of command out you
wish to have in a rdmatool ..

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
