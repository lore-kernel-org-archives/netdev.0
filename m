From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) interface
Date: Tue, 7 Feb 2017 17:04:47 -0800
Message-ID: <20170208010447.GB76793@knc-06.sc.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170207211901.GB28922@obsidianresearch.com>
 <20170207220628.GB76652@knc-06.sc.intel.com>
 <20170207221925.GA30579@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170207221925.GA30579-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2017 at 03:19:25PM -0700, Jason Gunthorpe wrote:
>On Tue, Feb 07, 2017 at 02:06:30PM -0800, Vishwanathapura, Niranjana wrote:
>
>> >> 	IB_DEVICE_RAW_SCATTER_FCS		= (1ULL << 34),
>> >>+	IB_DEVICE_RDMA_NETDEV_HFI_VNIC		= (1ULL << 35),
>> >
>> >What is this called HFI_VNIC anyhow? Shouldn't this be OPA_VNIC? There
>> >is nothing really HFI specific, right?
>>
>> Agreed, OPA_VNIC is more appropriate here. Will change it.
>
>And probably lots of other places too.. :)
>

Well, our driver is called HFI1 and HFI_VNIC is in accordance with our naming 
convention. I will only change the above device attribute name to OPA_VNIC in 
the ib interface just to be consitant with other such defintions here.

>
>> >And this should be rn->dev_priv ?
>>
>> Yah, both will result in same behavior. But yah, what you are suggesting
>> will remove any confusion. Will change in next PATCH series.
>
>Only because the struct has no members, as soon as someone adds
>something it would go booom.
>

Agreed.

>Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
