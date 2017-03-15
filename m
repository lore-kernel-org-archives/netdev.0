From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v1 for accelerated IPoIB 04/25] IB/verb: Add ipoib_options
 struct and API
Date: Wed, 15 Mar 2017 09:40:50 -0700
Message-ID: <20170315164050.GA81782@knc-06.sc.intel.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-5-git-send-email-erezsh@mellanox.com>
 <20170313200136.GA2738@obsidianresearch.com>
 <20170314070109.GD79937@knc-06.sc.intel.com>
 <20170314161149.GA15752@obsidianresearch.com>
 <20170315063043.GC2079@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170315063043.GC2079-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 15, 2017 at 08:30:43AM +0200, Leon Romanovsky wrote:
>On Tue, Mar 14, 2017 at 10:11:49AM -0600, Jason Gunthorpe wrote:
>> On Tue, Mar 14, 2017 at 12:01:09AM -0700, Vishwanathapura, Niranjana wrote:
>> > On Mon, Mar 13, 2017 at 02:01:36PM -0600, Jason Gunthorpe wrote:
>> > >>+	/* multicast */
>> > >>+	int (*attach_mcast)(struct net_device *dev, struct ib_device *hca,
>> > >>+			    union ib_gid *gid, u16 lid, int set_qkey);
>> > >>+	int (*detach_mcast)(struct net_device *dev, struct ib_device *hca,
>> > >>+			    union ib_gid *gid, u16 lid);
>> > >
>> > >It would make more sense to store the struct ib_device pointer in the
>> > >struct rdma_netdev.
>> > >
>> >
>> > Agree that it shouldn't be a function parameters.
>> > For opa_vnic, I found it convenient to store ib_device pointer in client and
>> > device private structures as those will be available in most places anyhow.
>>
>> If vnic uses it too, then lets add the ib_device and port num to
>> rdma_netdev itself?
>
>Agree, at the end this rdma_netdev is intended for the drivers/infiniband
>and it is better to have this binding (rdma_netdev and ib_device) as early as possible.
>

I agree with adding ibdev and port num to rdma_netdev.

Niranjana

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
