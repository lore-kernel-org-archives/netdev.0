From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: IFF_LOWER_UP does not fit in ifr_flags
Date: Thu, 11 Jun 2009 20:57:35 -0700 (PDT)
Message-ID: <20090611.205735.120685201.davem@davemloft.net>
References: <89A39FC0957640879F8975880836CF91@edgeware.tv>
	<20090529205028.3e01786b.akpm@linux-foundation.org>
	<1244219047.7969.7.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, fredrik.arnerup@edgeware.tv,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757434AbZFLD5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 23:57:33 -0400
In-Reply-To: <1244219047.7969.7.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Fri, 05 Jun 2009 16:24:07 +0000

> On Fri, 2009-05-29 at 20:50 -0700, Andrew Morton wrote:
>> On Thu, 28 May 2009 14:59:05 +0200 "Fredrik Arnerup" <fredrik.arnerup@edgeware.tv> wrote:
>> 
>> > Documentation/networking/operstates.txt (and netdevice(7)) claims that
>> > the flags IFF_LOWER_UP, IFF_DORMANT and IFF_ECHO can be read from user space
>> > using ioctl() with SIOCGIFFLAGS. Looking in include/linux/if.h however,
>> > the flags are returned in a struct ifreq in the field ifr_flags which
>> > is declared as a short, while the flags are defined as:
>> > 
>> > #define IFF_LOWER_UP    0x10000         /* driver signals L1 up         */
>> > #define IFF_DORMANT     0x20000         /* driver signals dormant       */
>> > #define IFF_ECHO        0x40000         /* echo sent packets            */
> 
> [PATCH] net core: Some interface flags not returned by SIOCGIFFLAGS
 ...
> Reported-by:  "Fredrik Arnerup" <fredrik.arnerup@edgeware.tv>
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

Applied, thanks!
