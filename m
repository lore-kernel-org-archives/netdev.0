From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000 speed/duplex error
Date: Wed, 2 Aug 2006 00:43:23 -0700
Message-ID: <9929d2390608020043y75b487c4ge5a02e7a6c96cb9b@mail.gmail.com>
References: <1301563340.20060801141827@mail.ru>
	 <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com>
	 <793732866.20060801153230@mail.ru>
	 <9929d2390608010445w4fd81b64g310ae90a423e1a7d@mail.gmail.com>
	 <911206621.20060801162006@mail.ru>
	 <9929d2390608010534x54324569ja70b1fcbdc23c097@mail.gmail.com>
	 <44CF66AD.1030901@intel.com> <168330902.20060802113402@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Auke Kok" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:2908 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751350AbWHBHnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 03:43:25 -0400
Received: by ug-out-1314.google.com with SMTP id m3so135078ugc
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2006 00:43:24 -0700 (PDT)
To: a1 <a1k@mail.ru>
In-Reply-To: <168330902.20060802113402@mail.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/2/06, a1 <a1k@mail.ru> wrote:
> Hi, Auke.
>
> Auke Kok wrote:
> AK> Here's that part of the driver documentation:
>
> AK> $ modprobe e1000 AutoNeg=0x08
> AK> e1000: 0000:00:00.0: e1000_validate_option: AutoNeg advertising 100/FD
>
>
> AK>   99 /* Auto-negotiation Advertisement Override
> AK> 100  *
> AK> 101  * Valid Range: 0x01-0x0F, 0x20-0x2F (copper); 0x20 (fiber)
> AK> 102  *
> AK> 103  * The AutoNeg value is a bit mask describing which speed and duplex
> AK> 104  * combinations should be advertised during auto-negotiation.
> AK> 105  * The supported speed and duplex modes are listed below
> AK> 106  *
> AK> 107  * Bit           7     6     5      4      3     2     1      0
> AK> 108  * Speed (Mbps)  N/A   N/A   1000   N/A    100   100   10     10
> AK> 109  * Duplex                    Full          Full  Half  Full   Half
> AK> 110  *
> AK> 111  * Default Value: 0x2F (copper); 0x20 (fiber)
> AK> 112  */
>
> This is not what I'm thinking of. Say, for example, I have a bunch of
> e1000 adapters in my box and want to dynamically change one's spd/dplx.
> For that works in the way you described I need to stop all of them and
> load with autoneg parameter (can I pass this parameter only to single
> card?) and loose all connection I had on other adapters.
> It would be better to handle it in ethtool way, since I discovered
> it's a common behavior.
> Thanks.
>
>
> AK> hth,
>
> AK> Auke
>
>
> --
> Best Regards,
>  Alexandr Kotov                       mailto:a1k@mail.ru
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

I agree.  Although ethtool does not have that functionality as of yet.
 Feel free to provide a patch to the ethtool maintainer (Jeff Garzik)
if you would like.  I will put it on my plate of things to do, but I
will admit that it is near the bottom of the list of items to get done
for me.  Feel free to ping me once in awhile to remind me.

-- 
Cheers,
Jeff
