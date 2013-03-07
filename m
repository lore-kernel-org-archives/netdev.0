From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: Set IFF_UNICAST_FLT flag to prevent unnecessary
 promisc mode.
Date: Thu, 07 Mar 2013 12:27:27 -0800
Message-ID: <5138F82F.6010005@candelatech.com>
References: <1362687708-8685-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40281 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933238Ab3CGU1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 15:27:30 -0500
In-Reply-To: <1362687708-8685-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2013 12:21 PM, Vlad Yasevich wrote:
> Macvlan already supports hw address filters.  Set the IFF_UNICAST_FLT
> so that it doesn't needlesly enter PROMISC mode when macvlans are
> stacked.

Out of curiosity, how can stacking mac-vlans be useful?

(You are stacking more macvlans on a base mac-vlan?)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
