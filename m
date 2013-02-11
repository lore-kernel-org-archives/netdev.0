From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH 1/2] net: calexdaxgmac: fix printing of hardware version
Date: Mon, 11 Feb 2013 10:59:53 +0000
Message-ID: <5118CF29.3040205@codethink.co.uk>
References: <1360510721-17860-1-git-send-email-ben.dooks@codethink.co.uk> <1360510721-17860-2-git-send-email-ben.dooks@codethink.co.uk> <5118208C.7010109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:42032 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366Ab3BKK7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 05:59:55 -0500
In-Reply-To: <5118208C.7010109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/13 22:34, Rob Herring wrote:
> On 02/10/2013 09:38 AM, Ben Dooks wrote:
>> The current driver attempts to print netdev_info() before registering the
>> network device and allowing the name to be set. Change this print to be
>> after the network deviec has been registered, and thus has been allocated
>
> You missed the typo pointed out on the first version sent to lakml.

Oops, sorry.

>> a network device name.
>>
>> Fix the following issue:
>>
>> calxedaxgmac fff50000.ethernet (unregistered net_device): h/w version is 0x1012
>>
>> Signed-off-by: Ben Dooks<ben.dooks@codethink.co.uk>
>
> Otherwise,
>
> Acked-by: Rob Herring<rob.herring@calxeda.com>

Thanks.


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
