From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPIP: Allow rebinding the tunnel to another interface
Date: Wed, 12 Dec 2007 17:33:44 +0100
Message-ID: <47600D68.2000501@trash.net>
References: <20071212163451.498b5726@brian.englab.brq.redhat.com>	<4760058E.5080403@trash.net> <20071212172933.178cf78e@brian.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcela Maslanova <mmaslano@redhat.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49937 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759110AbXLLQdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 11:33:54 -0500
In-Reply-To: <20071212172933.178cf78e@brian.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Schmidt wrote:
> On Wed, 12 Dec 2007 17:00:14 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> If you change dev->iflink this should trigger a rtnetlink
>> notification.
> 
> OK, I've added netdev_state_change(dev). Here's the new patch.


Looks good to me, thanks.
