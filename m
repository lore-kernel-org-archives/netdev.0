From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V1 08/16] i40iw: add files for iwarp interface
Date: Wed, 23 Dec 2015 18:42:01 +0200
Message-ID: <567ACED9.2040701@mellanox.com>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-2-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-3-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-4-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-5-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-6-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-7-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-8-git-send-email-faisal.latif@intel.com>
 <1450739596-23276-9-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450739596-23276-9-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/22/2015 1:13 AM, Faisal Latif wrote:
> +
> +enum i40iw_memreg_type {
> +	IW_MEMREG_TYPE_MEM = 0x0000,
> +	IW_MEMREG_TYPE_QP = 0x0001,
> +	IW_MEMREG_TYPE_CQ = 0x0002,
> +	IW_MEMREG_TYPE_MW = 0x0003,
> +	IW_MEMREG_TYPE_FMR = 0x0004,
> +	IW_MEMREG_TYPE_FMEM = 0x0005,
> +};

Can't you re-use IB core values or derive that from the actual uverbs 
command?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
