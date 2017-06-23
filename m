From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] nfc: nci: remove unnecessary null check
Date: Thu, 22 Jun 2017 20:25:52 -0500
Message-ID: <20170622202552.Horde.GxVvc-eDjUx8yLnS-c2r82L@gator4166.hostgator.com>
References: <28317503-e721-2564-a9ff-82182aa0644a@roeck-us.net>
 <20170613163718.GA5375@embeddedgus>
 <20170622223524.GG21214@zurbaran.ger.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway23.websitewelcome.com ([192.185.48.251]:29276 "EHLO
        gateway23.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752832AbdFWBZz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 21:25:55 -0400
Received: from cm11.websitewelcome.com (cm11.websitewelcome.com [100.42.49.5])
        by gateway23.websitewelcome.com (Postfix) with ESMTP id B33DE17AC8
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 20:25:52 -0500 (CDT)
In-Reply-To: <20170622223524.GG21214@zurbaran.ger.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Samuel,

Quoting Samuel Ortiz <sameo@linux.intel.com>:

> Hi Gustavo,
>
> On Tue, Jun 13, 2017 at 11:37:18AM -0500, Gustavo A. R. Silva wrote:
>> Remove unnecessary NULL check for pointer conn_info.
>> conn_info is set in list_for_each_entry() using container_of(),
>> which is never NULL.
>>
>> Addresses-Coverity-ID: 1362349
>> Cc: Guenter Roeck <linux@roeck-us.net>
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> ---
>>  net/nfc/nci/core.c | 9 ++++-----
>>  1 file changed, 4 insertions(+), 5 deletions(-)
> Applied to nfc-next, thanks.
>

Absolutely, glad to help.

Thanks
