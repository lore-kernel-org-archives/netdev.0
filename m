From: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>
Subject: Re: [PATCH] net/core: Make urgent data inline by default
Date: Tue, 5 Jul 2011 08:41:50 +0300
Message-ID: <op.vx4sr0o86ywr33@esapekka-pc.rad1>
References: <op.vx3hzgtw6ywr33@esapekka-pc.rad1>
 <20110704.163838.1746904172195321123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hki-smtp-1b.stonesoft.com ([84.34.144.100]:41726 "EHLO
	hki-smtp-1b.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab1GEFly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 01:41:54 -0400
In-Reply-To: <20110704.163838.1746904172195321123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Jul 2011 02:38:38 +0300, David Miller <davem@davemloft.net>  
wrote:

> There is no way we can make this change, we've had the default
> we currently have for 18+ years.  Breaking applications is a
> very real possibility.
>
> It doesn't matter what some RFC says.

I understand. However urgent pointer is a very niche feature and I don't  
think
it would really break much. FTP and telnet both want the urgent data inline
anyway. I haven't found any application which uses the "1-byte" urgent  
data,
which can by some change be overwritten by the next urgent data if you  
didn't
read it in time. The reason I would want this change is that attack  
detection
is very difficult when there can be a byte missing due to URG flag being  
set,
and the damage done by crackers is more than the damage to applications I  
think.
But I guess you decide. Atleast I tried.

Esa-Pekka
