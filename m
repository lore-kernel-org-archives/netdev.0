From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netdev: tilepro: Use
 is_multicast_ether_addr helper
Date: Wed, 12 Jan 2011 18:45:01 -0800 (PST)
Message-ID: <20110112.184501.00455226.davem@davemloft.net>
References: <1294824713-10644-1-git-send-email-tklauser@distanz.ch>
	<4D2DE98F.1090705@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tklauser@distanz.ch, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56512
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932612Ab1AMCo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 21:44:29 -0500
In-Reply-To: <4D2DE98F.1090705@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Wed, 12 Jan 2011 12:49:03 -0500

> On 1/12/2011 4:31 AM, Tobias Klauser wrote:
>> Use is_multicast_ether_addr from linux/etherdevice.h instead of a custom
>> macro. Also remove the broadcast address check, as it is considered a
>> multicast address too.
>>
>> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
>> ---
>>  drivers/net/tile/tilepro.c |   10 +---------
>>  1 files changed, 1 insertions(+), 9 deletions(-)
> 
> Thanks, I've taken this into the Tilera tree!

Don't, his transformation is buggy.

You can't get rid of the broadcast check, it needs to be there.
Think about it.
