From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fsl_pq_mdio: use spin_event_timeout() to poll the
 indicator register
Date: Mon, 09 Jul 2012 14:17:14 -0700 (PDT)
Message-ID: <20120709.141714.1072959067688919521.davem@davemloft.net>
References: <1341357381-10861-1-git-send-email-timur@freescale.com>
	<20120708.235926.1117975937932919247.davem@davemloft.net>
	<4FFAEB44.2030600@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: B04825@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab2GIVRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 17:17:15 -0400
In-Reply-To: <4FFAEB44.2030600@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tabi Timur-B04825 <B04825@freescale.com>
Date: Mon, 9 Jul 2012 14:31:33 +0000

> David Miller wrote:
> 
>> Define a macro for the timeout value rather than use an arbitrary
>> constant.
> 
> Ok.
> 
>>> +	status = spin_event_timeout(!(in_be32(&regs->miimind) &	MIIMIND_BUSY),
>>> +		1000, 0);
>>
>> This indentation is absolutely terrible.
> 
> Can you give me a clue as to how you think it should look?  I could not 
> come up with a good way to break up these lines and keep them under 80 
> characters.

It's not the length of the first line, it's how the second line was
indented.

Always line up the arguments on the second and subsequent lines right
after the column containing the openning "(" on the first line.

	foo = function(arg1,
		       arg2);

Do you really mean that:

	foo = function(arg1,
		arg2);

doesn't look like complete and utter shit to you?
