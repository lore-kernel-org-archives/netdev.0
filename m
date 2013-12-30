From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: IRQ cannot be shared
Date: Sun, 29 Dec 2013 22:35:44 -0500 (EST)
Message-ID: <20131229.223544.776831699070481195.davem@davemloft.net>
References: <CAGVrzcaUamisoHrW-j5RCt4ph=s0X32uUi7yn7_Wi7=5fxi7tw@mail.gmail.com>
	<20131227.134333.1370704464169101441.davem@davemloft.net>
	<52BDDAC4.2050100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454Ab3L3Dfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 22:35:45 -0500
In-Reply-To: <52BDDAC4.2050100@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 27 Dec 2013 22:53:40 +0300

>> Arguably they are broken,
> 
>    Yes, they already are.
> 
>> but they are least mostly working right now
>> and probes will completely fail after this change.
> 
>    I don't see how the probes will fail. Have you seen the surrounding
>    code? It should just switch to PHY polling if request_irq() fails and
>    return 0. Am I missing something?

Indeed, right you are.

Applied, thanks.
