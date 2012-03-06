From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] vlan: Support sending custom Ethernet CRC.
Date: Mon, 05 Mar 2012 19:59:57 -0800
Message-ID: <4F558BBD.1050400@candelatech.com>
References: <1330999558-14270-1-git-send-email-greearb@candelatech.com> <20120305.211449.2159840360912052625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54663 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757895Ab2CFEAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 23:00:03 -0500
In-Reply-To: <20120305.211449.2159840360912052625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2012 06:14 PM, David Miller wrote:
> From: greearb@candelatech.com
> Date: Mon,  5 Mar 2012 18:05:58 -0800
>
>> NOTE:  You will probably have to disable any
>> VLAN hardware assist on the underlying device to get
>> this to properly send packets with this feature enabled.
>
> This need to be therefore handled specifically on a device-by-device
> basis, and VLAN custom CRC disabled unless the device explicitly
> states that it can handle this situation properly and has any
> necessary feature rule enforcement codified.

I'll see what I can come up with.  Maybe figure out how to propagate
a flag up from the NIC when it is in a state that can handle VLAN + custom-CRC
and only enable the flag on the VLAN in that case...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
