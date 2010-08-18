From: David Miller <davem@davemloft.net>
Subject: Re: GTSM and TCP accept problem
Date: Wed, 18 Aug 2010 14:48:37 -0700 (PDT)
Message-ID: <20100818.144837.179941999.davem@davemloft.net>
References: <20100814214634.24a87715@s6510>
	<1281951825.2524.5.camel@edumazet-laptop>
	<20100818143913.1478acea@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753823Ab0HRVsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 17:48:18 -0400
In-Reply-To: <20100818143913.1478acea@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 18 Aug 2010 14:39:13 -0700

> On Mon, 16 Aug 2010 11:43:45 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> Another idea would be to store the TTL of the SYN packet (or third
>> packet) and let application read it after accept(), allowing it to
>> reject the connection if it doesnt match expected TTL.
> 
> could be in tcp_info?

I'm sure we can squeeze a byte out of there :-)
