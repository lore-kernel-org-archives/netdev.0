From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: Re: [PATCH v2 00/17] IB/Verbs: IB Management Helpers
Date: Wed, 08 Apr 2015 14:41:18 +0200
Message-ID: <552521EE.5060206@profitbricks.com>
References: <5523CCD5.6030401@profitbricks.com> <5525132F.1020004@talpey.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Mike Marciniszyn <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ilya Nelkenbaum <ilyan-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Tom Talpey <tom-CLs1Zie5N5HQT0dZR+AlfA@public.gmane.org>, Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5525132F.1020004-CLs1Zie5N5HQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 04/08/2015 01:38 PM, Tom Talpey wrote:
> On 4/7/2015 8:25 AM, Michael Wang wrote:
>> Mapping List:
>>         node-type    link-layer    old-transport    new-transport
>> nes        RNIC        ETH        IWARP        IWARP
>> amso1100    RNIC        ETH        IWARP        IWARP
>> cxgb3       RNIC        ETH        IWARP        IWARP
>> cxgb4       RNIC        ETH        IWARP        IWARP
>> usnic       USNIC_UDP    ETH        USNIC_UDP    USNIC_UDP
>> ocrdma      IB_CA        ETH        IB        IBOE
>> mlx4        IB_CA        IB/ETH        IB        IB/IBOE
>> mlx5        IB_CA        IB        IB        IB
>> ehca        IB_CA        IB        IB        IB
>> ipath       IB_CA        IB        IB        IB
>> mthca       IB_CA        IB        IB        IB
>> qib         IB_CA        IB        IB        IB
> 
> Can I rewind to ask a high-level question - what's the testing
> plan for all of this? Do you have folks lined up for verifying
> each of these adapters/networks, and what tests will they run?

I think no one can have the access to all these hardware, so we can
only depends on those who accidentally have one to help the testing,
but it's still far from that stage..

Besides, the logical is not very complex in this part, all the
mapping could find corresponding code as proof, so reviewing
carefully then give a public testing on some tree may could be
a plan too?

But yes, I won't be able to give an exhaustive testing by myself
and no one is backing me on that currently :-P me too are waiting
for the answers on how to assure the quality for patch set like this...

Regards,
Michael Wang

> 
> 
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
