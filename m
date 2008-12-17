From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [PATCH 0/2] tlan: fix earlier fixes, remove big buffer mode
Date: Wed, 17 Dec 2008 23:26:39 +0200
Message-ID: <49496E8F.1000207@iki.fi>
References: <4947C842.1020503@iki.fi> <20081216.152215.48045394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw01.mail.saunalahti.fi ([195.197.172.115]:43691 "EHLO
	gw01.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbYLQV0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:26:43 -0500
In-Reply-To: <20081216.152215.48045394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Sakari Ailus <sakari.ailus@iki.fi>
> Date: Tue, 16 Dec 2008 17:24:50 +0200
> 
>> Unfortunately it seems that my last patch introduced a few problems.
>>
>> So here are two patches: the first one fixes the pci memory
>> unmapping. The second one removes the big buffer mode.
> 
> I think what I'm going to do is put your first patch into
> net-2.6 and the bigbuf removal into net-next-2.6

Sounds good, thanks!

> Yes I realize that your changes might have made bigbuf even
> more broken than it already is, that's fine since it's
> off by default.

On second though, I don't think the bbuf mode was broken by my patches
more than it already was. skb_copy_from_linear_data copies txlen bytes
from skb->data to tail_buffer. This is fine, since the skb has at least
that many bytes and tail_buffer is at least as big, too. One should
never make this kind of claims when too tired... ;)

But the bottom line is still that the bbuf mode doesn't work.

-- 
Sakari Ailus
sakari.ailus@iki.fi

