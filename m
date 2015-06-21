From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 07/11] IB/cma: Helper functions to access port space IDRs
Date: Sun, 21 Jun 2015 15:51:45 +0300
Message-ID: <5586B361.7060500@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-8-git-send-email-haggaie@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A82373A8FF5AF3@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FF5AF3-P5GAC/sN6hkd3b2yrw5b5LfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16/06/2015 01:36, Hefty, Sean wrote:
>> Add helper functions to access the IDRs by port-space and port number.
>>
>> Pass around the port-space enum in cma.c instead of using pointers to
>> port-space IDRs.
> 
> What is the motivation for this change?

In the next patch ("IB/cma: Add net_dev and private data checks to RDMA
CM"), in cma_id_from_event(), I pass the port-space that is extracted
from the service ID to cma_ps_find(). Without this patch, I would need
to find the correct port-space IDR, effectively duplicating the code in
cma_select_inet_ps().

Regards,
Haggai

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
