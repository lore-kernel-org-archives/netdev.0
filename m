From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [V2 PATCH 2/9] csiostor: Chelsio FCoE offload driver submission
 (sources part 2).
Date: Wed, 5 Sep 2012 23:13:46 +0530
Message-ID: <50478F52.208@chelsio.com>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com> <1346848442-4573-3-git-send-email-naresh@chelsio.com> <20120905092957.7d24187e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7427 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697Ab2IERoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 13:44:22 -0400
In-Reply-To: <20120905092957.7d24187e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/2012 9:59 PM, Stephen Hemminger wrote:
> On Wed,  5 Sep 2012 18:03:55 +0530
> Naresh Kumar Inna <naresh@chelsio.com> wrote:
> 
>> This patch contains code for driver initialization, driver resource
>> allocation and the Work Request module functionality. Driver initialization
>> includes module entry/exit points, registration with PCI, FC transport and
>> SCSI mid layer subsystems. The Work Request module provides services for
>> allocation of DMA queues, posting Work Requests on them and processing
>> completions.
>>
>> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
> 
> Although the comments say you are using proc fs, there is no
> code here related to that.

I will remove that comment.

> 
> Any use of debugfs must be conditional the DEBUG_FS kernel configuration
> parameter.  Your code probably will break if DEBUG_FS is not
> enabled.  For a possible alternative see how a sub-config parameter
> was added in sky2 driver.
> 

It appears that debugfs_create_dir() returns an error if DEBUG_FS is not
enabled. Considering the driver handles this error and continues
initialization, do you still think I should guard this code within DEBUG_FS?

Thanks.
