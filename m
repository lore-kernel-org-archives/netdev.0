From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net/stable] can bcm: fix tx_setup off-by-one errors
Date: Thu, 29 Sep 2011 10:04:40 +0200
Message-ID: <4E842698.8090107@hartkopp.net>
References: <4E7CCEB3.4050408@hartkopp.net>	<20110929.003317.223715542181691202.davem@davemloft.net>	<4E842266.9090407@hartkopp.net> <20110929.035809.1014076114218537552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, nautsch@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:25978 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab1I2IIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 04:08:41 -0400
In-Reply-To: <20110929.035809.1014076114218537552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/11 09:58, David Miller wrote:

> From: Oliver Hartkopp <socketcan@hartkopp.net>
> Date: Thu, 29 Sep 2011 09:46:46 +0200
> 
>> when backporting the patch to an older kernel we discovered a problem this
>> patch is introducing - which causes a new regression :-(
>>
>> Could you please revert this patch and dequeue it from stable?
> 
> It's already pushed out to the net GIT tree, I can't delete history so
> now the only thing I can do is add a butt-ugly revert commit this late
> in the -rcX which is terrible.
> 
> This patch was sitting out there for review for 6 days, which should
> have been more than enough time to audit it for problems.


Yeah, i'm really sorry about that.

As Linus didn't pull the latest changes, what would be your favorite then to
not revert the patch?

Sending a new fix that fixes the broken fix?

Regards,
Oliver
