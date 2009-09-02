From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Use 32bit read to read Y2_VAUX_AVAIL
Date: Tue, 01 Sep 2009 17:45:05 -0700 (PDT)
Message-ID: <20090901.174505.63658266.davem@davemloft.net>
References: <4A9D2793.1020502@ring3k.org>
	<20090901085757.47b5c09c@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mikem@ring3k.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755457AbZIBAou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:44:50 -0400
In-Reply-To: <20090901085757.47b5c09c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 1 Sep 2009 08:57:57 -0700

> On Tue, 01 Sep 2009 22:54:27 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
> 
>> B0_CTST is a 24bit register according to the vendor driver (sk98lin).
>> A 16bit read on B0_CTST will always return 0 for Y2_VAUX_AVAIL (1<<16),
>>  so use a 32bit read when testing Y2_VAUX_AVAIL
>> 
>> Signed-off-by: Mike McCormack <mikem@ring3k.org>
 ...
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
