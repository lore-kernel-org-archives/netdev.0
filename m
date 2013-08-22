From: David Miller <davem@davemloft.net>
Subject: Re: Performance regression 3.11 with macvlan between 2 linux
 guests (bisected)
Date: Thu, 22 Aug 2013 01:29:56 -0700 (PDT)
Message-ID: <20130822.012956.317193234029192175.davem@davemloft.net>
References: <52150145.7020801@redhat.com>
	<521502F6.5030005@redhat.com>
	<5215CA84.8070906@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org, mst@redhat.com,
	mjrosato@linux.vnet.ibm.com, jasowang@redhat.com
To: borntraeger@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab3HVI35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 04:29:57 -0400
In-Reply-To: <5215CA84.8070906@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Thu, 22 Aug 2013 10:23:32 +0200

> On 21/08/13 20:12, Vlad Yasevich wrote:
> 
>>>
>>> A corrected patch has been sent upstream.  We take into consideration
>>> the features on the target device that the user/vm has specified.
>>> If the VM has enabled the TSO flags, then nothing will happen to the
>>> GSO packet.  However, if the TSO flag is off, segmentation will be
>>> performed.
>> 
>> Particularly.  This commit should fix the issue:
>> commit a567dd6252263c8147b7269df5d03d9e31463e11
>>  macvtap: simplify usage of tap_features
> 
> Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>
> 
> The patch is still in net.git, but not in Linus git. Are we going to push this
> for 3.11?

Of course.  Anything in 'net' is intended to make it into Linus's tree.

I generally push things to Linus every week or two.
