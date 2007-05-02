From: Pavel Emelianov <xemul@sw.ru>
Subject: Re: [Devel] [PATCH] Virtual ethernet device (tunnel)
Date: Wed, 02 May 2007 16:27:52 +0400
Message-ID: <463883C8.6090003@sw.ru>
References: <46386DFB.7090109@sw.ru> <46387EFE.1080103@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	devel@openvz.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:16153 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755119AbXEBMW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 08:22:58 -0400
In-Reply-To: <46387EFE.1080103@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano wrote:
> Pavel Emelianov wrote:
>> Veth stands for Virtual ETHernet. It is a simple tunnel driver
>> that works at the link layer and looks like a pair of ethernet
>> devices interconnected with each other.
>>
>> Mainly it allows to communicate between network namespaces but
>> it can be used as is as well.
>>
>> Eric recently sent a similar driver called etun. This
>> implementation is closer to the OpenVZ one and it lacks
>> some unimportant features of etun driver (like ethtool_ops)
>> for simplicity.
>>
>> The general difference from etun is that a netlink interface
>> is used to create and destroy the pairs. The patch for an
>> ip utility is also provided.
> if etun and veth are similar, why didn't you put the netlink interface
> to the etun driver instead of sending a new driver ?

Alexey said, that he preferred the name "veth" to "etun".
So an incremental patch would look too bad.

>    -- Daniel
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

