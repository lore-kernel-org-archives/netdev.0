From: Ben Greear <greearb@candelatech.com>
Subject: Re: bridge vs macvlan performance
Date: Tue, 04 Aug 2009 22:50:29 -0700
Message-ID: <4A791DA5.3090202@candelatech.com>
References: <Pine.LNX.4.64.0908041650560.13803@zuben.voltaire.com>	<4A785824.2030500@candelatech.com> <4A790D24.9000008@voltaire.com> <4A790F35.60204@candelatech.com> <4A791BA2.1040503@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	Vytautas Valancius <vytautas.valancius@gmail.com>,
	Sapan Bhatia <sapanb@cs.princeton.edu>,
	virtualization@lists.linux-foundation.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38938 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933452AbZHEFuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 01:50:40 -0400
In-Reply-To: <4A791BA2.1040503@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Ben Greear wrote:
>> Well, it seems we could and should fix veth to work, but it will have 
>> to do equivalent work of copying  an skb most likely, so either way 
>> you'll probably get a big performance hit.
> Using the same pktgen script (i.e with clone=0) I see that a 
> veth-->bridge-->veth configuration gives about 400K PPS forwarding 
> performance where macvlan-->veth-->macvlan gives 680K PPS (again, I 
> made sure that the bridge has applied learning before I start the 
> test). Basically, both the bridge and macvlan use hash on the 
> destination mac in order to know to which device forward the packet, 
> is there anything in the bridge logic that can explain the gap? It 
> there something which isn't really apples-to-apples in this comparison?
A VETH has to send to it's peer, so your descriptions are a bit vague.

What are you really configuring?  Maybe show us your script or commands 
that set up each of these tests?

Ben

>
> Or.
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


