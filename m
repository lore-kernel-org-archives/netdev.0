From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Mon, 9 Jan 2017 19:39:54 -0800
Message-ID: <20170110033954.GA53664@knc-06.sc.intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20170109075104.GV15685@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170109075104.GV15685-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 09, 2017 at 09:51:04AM +0200, Leon Romanovsky wrote:
>On Thu, Dec 15, 2016 at 11:28:06AM -0500, Doug Ledford wrote:
>> On 12/15/2016 9:52 AM, ira.weiny wrote:
>>
>> 2) With more than 60% of the code being MAD related, and another
>> significant chunk being hfi related, and only a minor bit (20% maybe?)
>> being net related,
>
>Hi Doug and Ira,
>
>I may admit that I didn't read the code very deep, but from brief
>overview, I didn't find support for the claim the "60% code is MAD related".
>It looks like the opposite thing will be more accurate.
>
>Can you help me to understand this claim? How did you come to this
>conclusion?
>
>Thanks

Hi Leon,

Here is the breakdown of patches based on functionality.
In this series, patches #3..#8 compose hfi_vnic driver. In that, patches #4, #7 
and #8 are MAD focused (interfacing with MAD agent and handling MAD packets).
Patch #6 and half of #3 (_encap.c/h) are OPA encapsulation related. Patch #5 is 
netdev statistic related (which includes statistics MAD definitions).
So, only part of patch #3 (_netdev.c and _ethtool.c) deals with interfacing 
with netstack.
Those percentage numbers are based on actual lines of code in these patches 
(files).

We are also looking into Jason’s suggestion to make hfi_vnic interface to the 
bottom driver a generic interface. This will include moving some of the 
netstack interfacing to the bottom hfi1 driver.

Niranjana

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
