From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V1 08/16] i40iw: add files for iwarp interface
Date: Thu, 24 Dec 2015 10:25:08 +0200
Message-ID: <567BABE4.8080302@mellanox.com>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-2-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-3-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-4-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-5-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-6-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-7-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-8-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-9-git-send-email-faisal.latif@intel.com>
 <567ACED9.2040701@mellanox.com> <20151224073137.GB35696@flatif-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151224073137.GB35696@flatif-MOBL1>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/24/2015 9:31 AM, Faisal Latif wrote:
> On Wed, Dec 23, 2015 at 08:42:01AM -0800, Or Gerlitz wrote:
>> On 12/22/2015 1:13 AM, Faisal Latif wrote:
>>> +
>>> +enum i40iw_memreg_type {
>>> +	IW_MEMREG_TYPE_MEM = 0x0000,
>>> +	IW_MEMREG_TYPE_QP = 0x0001,
>>> +	IW_MEMREG_TYPE_CQ = 0x0002,
>>> +	IW_MEMREG_TYPE_MW = 0x0003,
>>> +	IW_MEMREG_TYPE_FMR = 0x0004,
>>> +	IW_MEMREG_TYPE_FMEM = 0x0005,
>>> +};
>> Can't you re-use IB core values or derive that from the actual uverbs
>> command?
> I did not see anything which will have types that I needed.

what do you need? what is the role of this enum?

> It will be confusing otherwise.


> I will be reducing number of types from here though.

so why some of it can go? is that deal values which aren't used by the code

Or.

> Thanks
> Faisal

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
