From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 11/14] tipc: Eliminate useless linked list initialization
Date: Wed, 18 Aug 2010 09:28:27 -0400
Message-ID: <4C6BDFFB.2050008@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>	<1282078816-11844-12-git-send-email-paul.gortmaker@windriver.com> <20100817.172930.226785324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58590 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab0HRN2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 09:28:30 -0400
In-Reply-To: <20100817.172930.226785324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-08-17 08:29 PM, David Miller wrote:
> From: Paul Gortmaker<paul.gortmaker@windriver.com>
> Date: Tue, 17 Aug 2010 17:00:13 -0400
> 
>> From: Allan Stephens<allan.stephens@windriver.com>
>>
>> Eliminate the initialization of the port_list field of a newly created
>> TIPC port, since the port is immediately added to TIPC's global list
>> of ports (which alters the port_list field).
>>
>> Signed-off-by: Allan Stephens<allan.stephens@windriver.com>
>> Signed-off-by: Paul Gortmaker<paul.gortmaker@windriver.com>
> 
> This is not correct.
> 
> INIT_LIST_HEAD() is mandatory for all new objects, since it may
> initialize debugging knobs and whatnot inside of the list_head object
> when certain debugging options are enabled.
> 
> Therefore it may never be elided.

Thanks, I should have come to the same conclusion when I was looking
at that one.

P.

