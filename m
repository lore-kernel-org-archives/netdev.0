From: Ben Greear <greearb@candelatech.com>
Subject: Re: Hi,
Date: Fri, 25 Oct 2013 22:04:08 -0700
Message-ID: <526B4D48.4070608@candelatech.com>
References: <526B4FEC020000B100033DCD@mailhost1.datacore.uk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Reynolds <JReynolds@datacore.uk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41316 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494Ab3JZFEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 01:04:15 -0400
In-Reply-To: <526B4FEC020000B100033DCD@mailhost1.datacore.uk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2013 09:15 PM, John Reynolds wrote:
> Hi,
> Is there a userspace API that can be used to determine if a network interface is a 802.1Q interface, and what its vlan id and parent interface is. it appears that SOICGIFPFLAGS is not supported and netdev_priv() is only available to drivers, or do I have to resort to parsing the /proc/net/* files ?
>
> regards

The netlink API has it.  You can use the 'ip' tool and parse it's text output,
though of course that is not an overly stable API.

I think the old VLAN ioctls are still in the kernel as well, so you can
use those like the 'vconfig' tool does.

http://www.candelatech.com/~greear/vlan.html

Please note that 'ip' is the way of the future and I have little interest
in actually supporting vconfig.

Thanks,
Ben

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
