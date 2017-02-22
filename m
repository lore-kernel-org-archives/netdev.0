From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 22 Feb 2017 00:43:06 -0800
Message-ID: <20170222084306.GA53674@knc-06.sc.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <HE1PR0501MB2812C133C408A8092A745F82B1460@HE1PR0501MB2812.eurprd05.prod.outlook.com>
 <20170213170935.GD25430@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170213170935.GD25430-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 13, 2017 at 10:09:35AM -0700, Jason Gunthorpe wrote:
>On Sun, Feb 12, 2017 at 01:26:35PM +0000, Liran Liss wrote:
>> > From: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:linux-rdma-
>> > owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Vishwanathapura, Niranjana
>>
>> >
>> > ChangeLog:
>> > =========
>> > v2 => v3:
>> > a) Introduce and adopt generic RDMA netdev interface including,
>> >      - having bottom hfi1 driver directly interfacing with netstack.
>> >      - optimizing interface between hfi_vnic and hfi1 driver.
>> > b) Remove bitfield usage.
>> > c) Move hfi_vnic driver to drivers/infiniband/ulp folder.
>>
>> The vnic driver should be placed under drivers/infiniband/hw/hfi1/*
>> since it is HFI-specific.
>
>I think they should call it opa_vnic and keep it in ulp to avoid this
>confusion.
>

Alright, I am renaming it as opa_vnic to avoid any confusion.

Thanks,
Niranjana

>Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
