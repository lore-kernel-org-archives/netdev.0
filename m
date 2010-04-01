From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 5/6] cxgb4: Add main driver file and driver Makefile
Date: Wed, 31 Mar 2010 18:34:31 -0700
Message-ID: <4BB3F827.3010402@chelsio.com>
References: <20100330141904.5236fe44@nehalam>	<20100330.225042.107712654.davem@davemloft.net>	<4BB3E689.4050001@chelsio.com> <20100331.172401.00333850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10324 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758559Ab0DABei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 21:34:38 -0400
In-Reply-To: <20100331.172401.00333850.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>> So, I propose getting rid of 3-4 of these files that are of lesser
>> value and moving the rest to debugfs for now.  If some alternative
>> through ethtool or something becomes available I can get rid of
>> anything that can be handled through a more general facility.  Would
>> that be acceptable?
> 
> You can use sysfs.

sysfs is a possibility but I thought Stephen's initial concern was that I 
was adding too many of these proc files and that they were creating a 
potential API.  sysfs will result in a lot more files with its 
value-per-file model and I think sysfs and proc are similar in "APIness". 
So it's not clear to me how going to sysfs would address Stephen's point. 
The remove-a-few plus move-to-debugfs proposal was in order to end up with 
fewer files in a non-API filesystem.

As these builtin switches become more common I expect an official way to 
represent and access them will emerge but maybe it's not a good idea to 
introduce a sysfs model for them as part of this driver submission.
