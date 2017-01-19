From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Thu, 19 Jan 2017 15:16:51 -0700
Message-ID: <20170119221651.GA1656@obsidianresearch.com>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
 <20170118173327.GF32481@mtr-leonro.local>
 <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
 <20170118183127.GC14198@obsidianresearch.com>
 <5f90fd26-e7bf-bb2a-01f2-6b166f2265e9@sandisk.com>
 <20170119063326.GJ32481@mtr-leonro.local>
 <20170119180308.GD8109@obsidianresearch.com>
 <1484863558.2634.7.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "leon@kernel.org" <leon@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "arielalmogworkemails@gmail.com" <arielalmogworkemails@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "gerlitz.or@gmail.com" <gerlitz.or@gmail.com>
To: Bart Van Assche <Bart.VanAssche@sandisk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:53008 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751822AbdASWRa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 17:17:30 -0500
Content-Disposition: inline
In-Reply-To: <1484863558.2634.7.camel@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2017 at 10:06:12PM +0000, Bart Van Assche wrote:
> On Thu, 2017-01-19 at 11:03 -0700, Jason Gunthorpe wrote:
> > sysfs is unpopular because the 'one value per file' dogma is laregly
> > unsuitable for complex mulit-value atomic changes which are common in
> > netdev. You can force it to work, but it is pretty horrible..
> > 
> > It is also very expensive if you want to shuttle a lot of data, eg I
> > could not see doing something like 'netstat' for IB through sysfs
> 
> Since the RDMA sysfs ABI defines a user space ABI and since user space
> ABIs must be backwards compatible removing the existing sysfs ABI is
> not an option. We will need to evaluate on a case-by-case basis whether
> new functionality should use sysfs or whether another mechanism should
> be used.

Not talking about getting rid of it.

But if it makes sense to use netlink for the new stuff we should make
netlink self-consistent so a netlink user does not have to fall back
to sysfs for certain things.

Jason
