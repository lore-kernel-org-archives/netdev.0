From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH bk-2.6.10] tg3:align IP headers from 5701 in PCI-X mode
Date: Mon, 10 Jan 2005 16:01:59 -0500
Message-ID: <41E2ED47.9080909@pobox.com>
References: <Pine.LNX.4.33.0501031713460.16417-100000@localhost.localdomain> <20050110125001.4fe4d00b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050110125001.4fe4d00b.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 3 Jan 2005 17:45:01 -0800 (PST)
> akepner@sgi.com wrote:
> 
> 
>>We still have customers using 5701 cards, and their syslogs fill with 
>>"kernel unaligned access" messages. They may also see a significant 
>>performance degradation due to the expense of unaligned accesses on 
>>ia64. Here's a patch to address this (it is almost the same as the 
>>patch which was discussed in 
>>http://marc.theaimsgroup.com/?l=linux-netdev&m=109770128816605&w=2).
>>
>>In a quick throughput test, I found that this could improve throughput
>>by ~30% on an Altix.
> 
> 
> Let's just do this all the time for this case, adding new config
> options for stuff like this does nothing more than create confusion.


agreed.

	Jeff
