From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 10:54:16 -0700
Message-ID: <4ADDF948.1050208@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44095 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbZJTRyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 13:54:17 -0400
In-Reply-To: <4ADDF6E5.4070509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2009 10:44 AM, Eric Dumazet wrote:

>
> Please try last kernel before posting patches :)

I should have looked at the latest code, but even if mac-vlan is no longer
an issue, I suspect it may still be possible to get into this case with
other virtual devices because pktgen plays tricks by cloning pkts.

That said, I have no proof, so no further arguments from me.

Thanks for pointing out the new mac-vlan patch.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

