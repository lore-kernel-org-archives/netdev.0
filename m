From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: use reciprocal divide
Date: Fri, 19 Nov 2010 10:07:26 -0800 (PST)
Message-ID: <20101119.100726.48508760.davem@davemloft.net>
References: <1290153398.29509.7.camel@edumazet-laptop>
	<1290153886.29509.10.camel@edumazet-laptop>
	<AANLkTi=qR==8g2Z_GeAOsczVmUS3yj1PnsOfoU7zbudG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hagen@jauu.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35791
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756194Ab0KSSHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 13:07:00 -0500
In-Reply-To: <AANLkTi=qR==8g2Z_GeAOsczVmUS3yj1PnsOfoU7zbudG@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 19 Nov 2010 16:18:05 +0800

> On Fri, Nov 19, 2010 at 4:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> At compile time, we can replace the DIV_K instruction (divide by a
>> constant value) by a reciprocal divide.
>>
>> At exec time, the expensive divide is replaced by a multiply, a less
>> expensive operation on most processors.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Changli Gao <xiaosuo@gmail.com>

Applied.
