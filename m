From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: export some settings using ethtool private flags
Date: Thu, 25 Mar 2010 13:30:24 -0400
Message-ID: <4BAB9DB0.7020203@garzik.org>
References: <20100227082305.GA18194@havoc.gtf.org> <EA929A9653AAE14F841771FB1DE5A1365FE4B3E5A7@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:49740 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab0CYRh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 13:37:57 -0400
Received: by pzk32 with SMTP id 32so1881557pzk.4
        for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 10:37:55 -0700 (PDT)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE4B3E5A7@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/2010 01:16 PM, Tantilov, Emil S wrote:
> Jeff Garzik wrote:
>> The ethtool private flags interface exists to get/set driver-specific
>> settings at runtime, in a flexible manner.
>>
>> Use this facility to export a couple e1000e features, that were
>> previously only set at module initialization time.
>>
>> Signed-off-by: Jeff Garzik<jgarzik@redhat.com>
>> ---
>>   drivers/net/e1000e/ethtool.c |   27 +++++++++++++++++++++++++++
>>   1 file changed, 27 insertions(+)
>
> Jeff,
>
> What is the use case for the ethtool private flags?

It is stated in the changelog above :)  It enables feature setting at 
setting, on an easy, per-network-interface basis, that were previously 
only settable at module initialization (ie. load) time.


> At least I don't see an option in ethtool that would make use of them.

This is added in a separate patch, since the above patch is the first to 
make use of the private-flags ethtool mechanism.

	Jeff


