From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH linux-next 1/4] infiniband/ipoib: fix possible NULL pointer
 dereference in ipoib_get_iflink
Date: Wed, 15 Apr 2015 08:24:07 +0300
Message-ID: <552DF5F7.8020800@mellanox.com>
References: <1429024817-21561-1-git-send-email-honli@redhat.com>
 <1429024817-21561-2-git-send-email-honli@redhat.com>
 <CAAk-MO-O9sjHQvDfCEuzJJPvUMXJTuRaCzrCkB0xc1DUfK8Aew@mail.gmail.com>
 <20150414204133.GJ7682@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alex Estrin <alex.estrin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	<jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	<elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>, <sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150414204133.GJ7682-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/14/2015 11:41 PM, Jason Gunthorpe wrote:

> Erez, you basically rewrote this, please make a proper patch with the Fixes and Reported-By credit for Honggang. Lets merge this through Dave M's tree right away.

Agree, Erez, add proper Fixes: XXX note and send a patch to netdev 
against net-next. No need for the lengthy crash dump there. Nicolas, 
next time you patch IPoIB, please cc linux-rdma.
Or.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
