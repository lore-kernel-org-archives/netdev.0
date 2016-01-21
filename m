From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Thu, 21 Jan 2016 09:32:14 -0600
Message-ID: <004401d15460$e77fa1b0$b67ee510$@opengridcomputing.com>
References: <1453318816-21672-1-git-send-email-faisal.latif@intel.com> <CAJ3xEMhxMzAVJUNbBHrG8hia2tcFJ4cuPHpq3t9p0FqPHfYX+Q@mail.gmail.com> <00cf01d153d5$e6248eb0$b26dac10$@opengridcomputing.com> <56A08E8F.7090602@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "'Or Gerlitz'" <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"'Doug Ledford'" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"'Linux Netdev List'" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"'Jeff Kirsher'" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "'Or Gerlitz'" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"'Faisal Latif'" <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56A08E8F.7090602-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On 1/21/2016 12:57 AM, Steve Wise wrote:
> > I also asked you why the port mapper code has to be present in each
> > iwarp driver and not part of the IB core stack, and you responded
> > "i40iw iwarp driver registers with port mapper and uses its services.
> > Beside that it is not the scope of the patch series"  -- well, it is
> > in the scope of upstream review to pose such questions, please
> > address.
> >
> >
> > There is a common service/API in the IB core for iWarp port mapping.  See drivers/infinbiand/core/iwpm*.c and
> include/rdma/iw_portmap.h.
> >
> >
> 
> Steve,
> 
> Okay, but I still don't follow why each vendor needs an RDMA_NL_YYY ID
> (RDMA_NL_C4IW, RDMA_NL_NES and now a new one  for this driver) of their own.
> 
> I see that the two current drivers actually use the same callbacks
> towards user-space, does each vendor uses a different user-space daemon,
> why?
> 
> Or.
>

Only a single user-space daemon is used.  Someone from Intel might have insight into the architecture and design.  Perhaps the intention is that individual drivers might want to have their own handlers for these various operations.  But currently they all use the core/common ones.
 
Steve.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
