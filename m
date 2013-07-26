From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH V3 1/4] RDMA/cma: Add IPv6 support for iWARP.
Date: Fri, 26 Jul 2013 05:42:53 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A823738456826E@ORSMSX109.amr.corp.intel.com>
References: <1372934447-16556-1-git-send-email-vipul@chelsio.com>
 <1372934447-16556-2-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	"roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org" <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	"Latif, Faisal" <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Nikolova, Tatyana E" <tatyana.e.nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372934447-16556-2-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> 
> This patch modifies the type of local_addr and remote_addr fields in struct
> iw_cm_id from struct sockaddr_in to struct sockaddr_storage to hold IPv6 and
> IPv4 addresses uniformly. It changes the references of local_addr and
> remote_addr in RDMA/cxgb4, RDMA/cxgb3, RDMA/nes and amso drivers such that
> build
> failure is avoided. However to be able to actully run the traffic over IPv6
> address respective drivers have to add supportive code.
> 
> Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

For the rdma_cm portion:

Reviewed-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
