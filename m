From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Mon, 17 Nov 2008 17:27:05 -0800
Message-ID: <9929d2390811171727m14571c8bg64909d346a3753a0@mail.gmail.com>
References: <20081117234207.854110282@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.246]:27783 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbYKRB1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 20:27:08 -0500
Received: by hs-out-0708.google.com with SMTP id 4so1208450hsl.5
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 17:27:05 -0800 (PST)
In-Reply-To: <20081117234207.854110282@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 17, 2008 at 3:42 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> This sequence of patches breaks the network device adminstration
> function table away from the network device data structure. It is
> a transitional API change (both keep working), and this set of patches
> hits a range of commonly used drivers. This should be enough to make sure
> both old and new interfaces get used and tested.
>
> --
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Did I miss a patch, or did you intentionally not convert ixgbe?

The following patches look find...
Patch 13/33 - e1000e
Patch 23/33 - e1000
Patch 25/33 - igb
Patch 26/33 - e100
Patch 29/33 - ixgb

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
