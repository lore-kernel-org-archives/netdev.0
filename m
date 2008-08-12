From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [Qdisc] Prioritizing traffic per vlan using qdisc.
Date: Mon, 11 Aug 2008 18:17:12 -0700
Message-ID: <20080811181712.462cb2cf@extreme>
References: <9D1E2BDCB5C57B46B56E6D80843439EB0598FBC9@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Pravin Bathija" <pbathija@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:37373 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722AbYHLBRO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 21:17:14 -0400
In-Reply-To: <9D1E2BDCB5C57B46B56E6D80843439EB0598FBC9@SDCEXCHANGE01.ad.amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Aug 2008 17:48:22 -0700
"Pravin Bathija" <pbathija@amcc.com> wrote:

> Using Linux 2.6.23 I want to create multiple Vlans for voice, data,
> video etc. The requirement is to prioritize each vlan on the ingress and
> egress. I am looking at qdisc to do this however without success. Could
> you please advise is there is a way to do this using qdisc tc(traffic
> control) commands. If not - is there another way to do this in Linux ?
> Any help would be greatly appreciated.
> 
> Thanks,
> Pravin
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

For 2.6.25, an addition to the tc meta match to allow matching on
vlan tag was added.  Using this it is possible to use meta match
to convert tag -> flowid then use the flowid with a priority
(or htb) queue.
