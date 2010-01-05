From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Tue, 05 Jan 2010 13:42:18 -0800 (PST)
Message-ID: <20100105.134218.258781374.davem@davemloft.net>
References: <20100105185732.GA30346@redhat.com>
	<4B43AEF6.6050701@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754200Ab0AEVmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 16:42:14 -0500
In-Reply-To: <4B43AEF6.6050701@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Tue, 05 Jan 2010 15:28:22 -0600

> On 01/05/2010 12:57 PM, Michael S. Tsirkin wrote:
>> When sending packets with a packet socket it is often necessary to set
>> protocol in msg_name: otherwise the protocol field in the skb will not
>> be set correctly.
> 
> What about automatically detecting the protocol from the data being sent
> to avoid the necessity of specifying it in the first place?

This limits packet socket usage to only protocols the kernel is aware
of, defeating part of the usefulness of the packet socket facility.
