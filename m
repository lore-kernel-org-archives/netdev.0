From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2 1/5] net:  Support ethtool ops for rx of errored frames.
Date: Sun, 19 Jun 2011 13:11:06 -0700
Message-ID: <4DFE57DA.8090404@candelatech.com>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com> <1308430045-24816-2-git-send-email-greearb@candelatech.com> <20110618213400.GA2741@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55777 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab1FSULN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 16:11:13 -0400
In-Reply-To: <20110618213400.GA2741@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2011 02:34 PM, Francois Romieu wrote:
> greearb@candelatech.com<greearb@candelatech.com>  :
> [...]
>> This can be useful when sniffing dodgy networks.
>
> Do you plan to add something similar - i.e. not per packet - for the Tx path ?

Ability to tx errored frames?  I posted a patch to enable sending
frames with custom (ie, invalid) Ethernet FCS, but you have to
enable it per-socket, and it will only work with AF_PACKET sockets.

Can you offer more details on what you are asking for?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
