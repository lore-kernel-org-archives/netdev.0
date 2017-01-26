From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: iproute2: using .maxattr = IFLA_VLAN_MAX??
Date: Thu, 26 Jan 2017 11:27:41 -0500
Message-ID: <588A237D.8030007@ti.com>
References: <58864115.4060608@ti.com>
 <9B0331B6EBBD0E4684FBFAEDA55776F93D496CA4@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "Rosen, Rami" <rami.rosen@intel.com>,
        "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:65071 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752790AbdAZQ1l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 11:27:41 -0500
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F93D496CA4@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2017 03:45 PM, Rosen, Rami wrote:
> Hi, Murali,
> 
>> This appears to be a cut-n-paste bug as the source is based on ip/iplink_vlan.c and should be fixed to IFLA_HSR_MAX. 
> 
> You are right.
> The "HSR section" indeed defines IFLA_HSR_MAX in include/linux/if_link.h of iproute2 as the max attributes number.
> 
> And in the top of ip/iplink_hsr.c you will find this comment, which enhances your assumption about the origin of this mistake:
> 
> /*
> ...
>      Based on iplink_vlan.c by Patrick McHardy <kaber@trash.net
> ...
>  */
> 
> Regards,
> Rami Rosen
> 
Hi, Rami,

Thanks for confirming. I will send out a patch for fixing this when I get a chance to 
test hsr for my work in the next few days.

-- 
Murali Karicheri
Linux Kernel, Keystone
