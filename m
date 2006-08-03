From: a1 <a1k@mail.ru>
Subject: Re: e1000 speed/duplex error
Date: Thu, 3 Aug 2006 11:51:18 +0400
Message-ID: <1141838417.20060803115118@mail.ru>
References: <1301563340.20060801141827@mail.ru> <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com> <793732866.20060801153230@mail.ru> <9929d2390608010445w4fd81b64g310ae90a423e1a7d@mail.gmail.com> <911206621.20060801162006@mail.ru> <9929d2390608010534x54324569ja70b1fcbdc23c097@mail.gmail.com> <44CF66AD.1030901@intel.com> <168330902.20060802113402@mail.ru> <9929d2390608020043y75b487c4ge5a02e7a6c96cb9b@mail.gmail.com> <1556642230.20060802123908@mail.ru> <44D0BE71.9080205@intel.com>
Reply-To: a1 <a1k@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6.mail.ru ([194.67.23.26]:8516 "EHLO mx6.mail.ru")
	by vger.kernel.org with ESMTP id S932376AbWHCHuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 03:50:50 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44D0BE71.9080205@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Auke.

Auke Kok wrote:
AK> Don't you mean this? :

AK> +                       hw->autoneg_advertised = ecmd->advertising |
AK> +                                                ADVERTISED_Autoneg |
AK> +                                                ADVERTISED_TP;

AK> and we'd also have to do this for fibre...
Yep. I've noticed that but I already sent message...

 >>
>>                 ecmd->advertising = hw->autoneg_advertised;
>>         } else
>>                 if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex))


AK> but that's not really what you want: the way ethtool works currently only
AK> allows you to pass *one* speed/duplex tuple and autonegotiate with that, or
AK> all (by omitting any speed/duplex tuple).

AK> ethtool needs some code that allows you to specify "autonegotiate 10_half or
AK> 100_full or 1000_full" (3 tuples, but not implying 100_half or 10_full). This
AK> is something mii-tool was able to do but this functionality never made it into
AK> ethtool AFAIK :)

AK> This is the most useful case for everyone, you can omit advertising gig link
AK> if you only have 100mbit switches and speed up link times that way etc.

I'm sure of that, but today before actual ethtool patch released will
this changes be included in the driver sources? In that case IMO no other
changes need to be done to support what you've been writing of...

AK> Auke



-- 
Best regards,
Alexandr Kotov                          mailto:a1k@mail.ru

