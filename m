From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sk98lin: planned removal
Date: Thu, 15 Feb 2007 05:19:24 -0500
Message-ID: <45D433AC.7030809@pobox.com>
References: <20070207091830.59f72f46@oldman> <20070207203215.bdf3908b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54682 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965771AbXBOKT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 05:19:27 -0500
In-Reply-To: <20070207203215.bdf3908b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Wed, 7 Feb 2007 09:18:30 -0800 Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
>> Document planned removal of sk98lin driver.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>> ---
>>  Documentation/feature-removal-schedule.txt |    7 +++++++
>>  1 files changed, 7 insertions(+), 0 deletions(-)
>>
>> diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
>> index 0ba6af0..d08a4af 100644
>> --- a/Documentation/feature-removal-schedule.txt
>> +++ b/Documentation/feature-removal-schedule.txt
>> @@ -325,3 +325,10 @@ Why:	Unmaintained for years, superceded 
>>  Who:	Jeff Garzik <jeff@garzik.org>
>>  
>>  ---------------------------
>> +
>> +What:   sk98lin network driver
>> +When:   July 2007
>> +Why:    In kernel tree version of driver is unmaintained. Sk98lin driver
>> +	replaced by the skge driver. 
>> +Who:    Stephen Hemminger <shemminger@osdl.org>
>> +
> 
> People don't read that file.  I'd suggest the addition of a warning printk
> to the driver's open() method.

Fine with me.  Stephen, wanna cook up a patch?

	Jeff



