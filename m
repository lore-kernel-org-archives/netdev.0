From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 04/12] IB/ipoib: Return IPoIB devices matching
 connection parameters
Date: Thu, 21 May 2015 13:31:32 +0300
Message-ID: <CAJ3xEMje-Vm=6Z-gzoof8Jtcx1ayO_VAAmz4nhJLOCGGwrefKA@mail.gmail.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	<1431841868-28063-5-git-send-email-haggaie@mellanox.com>
	<20150519235502.GB26634@obsidianresearch.com>
	<555D6E41.10606@mellanox.com>
	<CAJ3xEMjN+o=vC4abAeG5EuOo3Y1gSyh1qPDseA_aaYmoLWAunw@mail.gmail.com>
	<555D7C4A.2060708@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <555D7C4A.2060708-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 21, 2015 at 9:33 AM, Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:

>> you can use non default pkeys as well here.
>> $ ip link add link ib0 name ib0.1 type ipoib pkey 0x8001

> Right. I think when we started development of the namespaces patches
> these child interfaces (rtnetlink with pkey) didn't work for us, but I
> checked now on an updated kernel and they do.

The last change to drivers/infiniband/ulp/ipoib/ipoib_netlink.c took
place on 3.12, well before you started... could be that you provided
wrong command line and such, I haven't seen any bug report nor fix
from you group to that area of the kernel.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
