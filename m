From: Roman Yeryomin <roman@advem.lv>
Subject: RE: [PATCH net-next 00/10] korina cleanups/optimizations
Date: Sun, 22 Oct 2017 23:58:19 +0300
Message-ID: <a6d61e0175b03d0e71bee1e5139b02e9@advem.lv>
References: <20171015162226.606-1-roman@advem.lv>
 <063D6719AE5E284EB5DD2968C1650D6DD0097CDD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:48601 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S932092AbdJVU6U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Oct 2017 16:58:20 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0097CDD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-16 15:59, David Laight wrote:
> From: Roman Yeryomin
>> Sent: 15 October 2017 17:22
>> TX optimizations have led to ~15% performance increase (35->40Mbps)
>> in local tx usecase (tested with iperf v3.2).
> 
> Indicate which patches give the improvement.
> IIRC some just changed the source without changing what the code really 
> did.
> (Not a problem in itself.)

Yes, this was mostly a cleanup.

> ...
>>   net: korina: optimize tx/rx interrupt handlers
> 
> You'd probably get a noticeable improvement from caching the
> value of the interrupt mask - instead of reading it from the hardware.
> ...
> 

Yeah, tried that, but have some problems measuring the results (that is 
don't see any improvements with iperf3, see other email)
But thanks for comment!

Regards,
Roman
