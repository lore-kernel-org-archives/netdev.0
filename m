From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 8 Sep 2011 22:33:33 +0300
Message-ID: <20110908193332.GA2476@redhat.com>
References: <1315503765.11074.33.camel@w-sridhar.beaverton.ibm.com>
 <CA8E645C.33B90%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	dragos.tatulea@gmail.com, arnd@arndb.de, dwang2@cisco.com,
	benve@cisco.com, kaber@trash.net, davem@davemloft.net,
	eric.dumazet@gmail.com, mchan@broadcom.com, kvm@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA8E645C.33B90%roprabhu@cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 08, 2011 at 12:23:56PM -0700, Roopa Prabhu wrote:
> > 
> > I think the main usecase for passthru mode is to assign a SR-IOV VF to
> > a single guest.
> > 
> Yes and for the passthru usecase this patch should be enough to enable
> filtering in hw (eventually like I indicated before I need to fix vlan
> filtering too).

So with filtering in hw, and in sriov VF case, VFs
actually share a filtering table. How will that
be partitioned?

-- 
MST
