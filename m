From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH for-next 2/2] net/mlx5: Update mlx5_ifc hardware features
Date: Tue, 12 Apr 2016 00:37:34 +0300
Message-ID: <CAJ3xEMhorMRsxtawjim9zoBn-zzoDXcMAJfHUqCZBNUbOKrMJA@mail.gmail.com>
References: <1460405422-8654-1-git-send-email-saeedm@mellanox.com>
	<1460405422-8654-3-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMghu7ZB0YM8j_YJihpuNnDzOY2LU9-cTHwoWiBeYY7VPA@mail.gmail.com>
	<CALzJLG-PxUz9ov+cv4uiNSGpuxy0s9KamTvamV_g72SctqdhFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG-PxUz9ov+cv4uiNSGpuxy0s9KamTvamV_g72SctqdhFA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 12, 2016 at 12:24 AM, Saeed Mahameed
<saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
> On Tue, Apr 12, 2016 at 12:17 AM, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

>> feature --> features

> Correct, will fix.

>>> * Add vport to steering commands for SRIOV ACL support
>>> * Add mlcr, pcmr and mcia registers for dump module EEPROM
>>> * Add support for FCS, baeacon led and disable_link bits to hca caps
>>> * Add CQE period mode bit in  CQ context for CQE based CQ
>>>   moderation support
>>> * Add umr SQ bit for fragmented memory registration
>>> * Add needed bits and caps for Striding RQ support

>> AFAIK, all the above are features will go through net-next, what made
>> you anticipate conflicts with linux-rdma?

> FCS bit is needed also for rdma, so we took the liberty of updating
> all the needed HW structs, bits, caps, etc ..
> at once for all mlx5 features planned for 4.7 regardless of rdma/net conflicts.

The cover letter states that this series deals with shared code.

I guess you might also could extend it a bit to deal also with code
that you suspect could lead to conflicts, but I don't see why it
evolved to that extent.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
