From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Fri, 31 May 2013 10:17:04 -0500
Message-ID: <20130531151704.GA2910@sbohrermbp13-local.rgmadvisors.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
 <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com>
 <20130525151347.GB25744@lintop.rgmadvisors.com>
 <20130528201508.GA6409@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZLZmLi3V-3D_16FZHQLsCsHKZY7ZhvaEH1k=Pw_i+ciwQ@mail.gmail.com>
 <20130530203113.GA4891@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZ+YSWhz0Hw+BWHeT=cEDqRj-s7uY4M-5CTiXcRgJND_+Q@mail.gmail.com>
 <51A7BD42.8060504@redhat.com>
 <20365.1369959800@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevic@redhat.com, Or Gerlitz <or.gerlitz@gmail.com>,
	netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Jiri Pirko <jiri@resnulli.us>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f47.google.com ([209.85.212.47]:43410 "EHLO
	mail-vb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614Ab3EaPRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 11:17:16 -0400
Received: by mail-vb0-f47.google.com with SMTP id x13so1112873vbb.20
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 08:17:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20365.1369959800@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 05:23:20PM -0700, Jay Vosburgh wrote:
> Vlad Yasevich <vyasevic@redhat.com> wrote:
> 
> >>>      CC: Jiri Pirko <jiri@resnulli.us>
> >>>      Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> >>>      Signed-off-by: David S. Miller <davem@davemloft.net>
> >>>
> >>> I've confirmed that reverting this patch on top of 3.10-rc3 allows me
> >>> to receive packets on all of my multicast groups without the Mellanox
> >>> high_rate_steer option set.
> >>
> >> OK, impressive debugging... so what do we do from here? Vlad, Shawn
> >> observes a regression once this patch is used on a large scale setup
> >> that uses many multicast groups (you can read the posts done earlier
> >> on this thread), does this rings any bell w.r.t to the actual problem
> >> in the patch?
> >
> >I haven't seen that, but I didn't test with that many multicast groups. I
> >had 20 groups working.
> >
> >I'll take a look and see what might be going on.
> 
> 	I've actually been porting bonding to the dev_sync/unsync
> system, and have a patch series of 4 fixes to various internals of
> dev_sync/unsync; I'll post those under separate cover.  It may be that
> one or more of those things are the source of this problem (or I might
> have it all wrong).

Thanks Jay,

I've tested your 4 patches on top of Linus' tree and they do solve the
multicast issue I was seeing in this thread.

--
Shawn
