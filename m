From: Ben Greear <greearb@candelatech.com>
Subject: Re: some veth related issues
Date: Tue, 04 Aug 2009 21:48:53 -0700
Message-ID: <4A790F35.60204@candelatech.com>
References: <Pine.LNX.4.64.0908041650560.13803@zuben.voltaire.com> <4A785824.2030500@candelatech.com> <4A790D24.9000008@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33258 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbZHEEsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 00:48:53 -0400
In-Reply-To: <4A790D24.9000008@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Ben Greear wrote:
>> Try setting clone to 0. Might be that sending cloned pkts over veth 
>> is a bad idea.
>
> okay, thanks, this fixed the problem, however it seems there's some 
> performance loss, with cloning I saw numbers of 500K 
> packets-per-second and above where without cloning I get about 400K PPS.
Well, it seems we could and should fix veth to work, but it will have to 
do equivalent work of copying
an skb most likely, so either way you'll probably get a big performance hit.

Thanks,
Ben
>
> Or.


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


