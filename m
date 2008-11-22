From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [NET-NEXT v4 PATCH 1/5] ixgbe: this patch adds support for DCB to the kernel and ixgbe driver
Date: Fri, 21 Nov 2008 16:57:12 -0800
Message-ID: <9929d2390811211657g7443bafex6aef259939dcbdc2@mail.gmail.com>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
	 <4926B26C.7010200@trash.net> <adaabbtgdv6.fsf@cisco.com>
	 <20081121.164812.237199469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, kaber@trash.net, netdev@vger.kernel.org,
	jeff@garzik.org, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:34073 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbYKVA5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:57:13 -0500
Received: by yx-out-2324.google.com with SMTP id 8so537228yxm.1
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 16:57:12 -0800 (PST)
In-Reply-To: <20081121.164812.237199469.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 4:48 PM, David Miller <davem@davemloft.net> wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Fri, 21 Nov 2008 09:58:37 -0800
>
>>  > > +
>>  > > +config DCBNL
>>  > > +        bool "Data Center Bridging netlink interface support"
>>  > > +        depends on DCB
>>  > > +        default n
>>  > > +        ---help---
>>  > > +          This option turns on the netlink interface
>>  > > +          (dcbnl) for Data Center Bridging capable devices.
>>  > > +
>>  > > +          If unsure, say N.
>>
>> Now that I look at this config, it looks rather strange.  When does is
>> ever make sense to enable DCB but not DCBNL?  How else does one
>> configure all the DCB parameters except by running dcbd in userspace?
>> Should there even be a separate DCBNL option at all?
>
> Yes, that makes sense.
>
> If DCBNL is the only way to enable and control DCB, there is no sense
> to have two seperate options.
> --
>

Sounds fine with me.  I will get a patch out later.

-- 
Cheers,
Jeff
