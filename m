From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [PATCH] net/fsl_pq_mdio: use spin_event_timeout() to poll the
 indicator register
Date: Mon, 9 Jul 2012 14:31:33 +0000
Message-ID: <4FFAEB44.2030600@freescale.com>
References: <1341357381-10861-1-git-send-email-timur@freescale.com>
 <20120708.235926.1117975937932919247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Fleming Andy-AFLEMING <afleming@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:36205
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750882Ab2GIOcC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2012 10:32:02 -0400
In-Reply-To: <20120708.235926.1117975937932919247.davem@davemloft.net>
Content-Language: en-US
Content-ID: <3AA3F27BBAAE1D4BB0CA8212FA257A2C@mgd.freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> Define a macro for the timeout value rather than use an arbitrary
> constant.

Ok.

>> +	status = spin_event_timeout(!(in_be32(&regs->miimind) &	MIIMIND_BUSY),
>> +		1000, 0);
>
> This indentation is absolutely terrible.

Can you give me a clue as to how you think it should look?  I could not 
come up with a good way to break up these lines and keep them under 80 
characters.

-- 
Timur Tabi
Linux kernel developer at Freescale
