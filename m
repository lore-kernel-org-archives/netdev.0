From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [V2 PATCH 6/9] csiostor: Chelsio FCoE offload driver submission
 (headers part 1).
Date: Wed, 5 Sep 2012 23:14:30 +0530
Message-ID: <50478F7E.1020606@chelsio.com>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com> <1346848442-4573-7-git-send-email-naresh@chelsio.com> <20120905093305.2418eac8@nehalam.linuxnetplumber.net>
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
Received: from stargate.chelsio.com ([67.207.112.58]:29690 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754555Ab2IERor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 13:44:47 -0400
In-Reply-To: <20120905093305.2418eac8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/5/2012 10:03 PM, Stephen Hemminger wrote:
> On Wed,  5 Sep 2012 18:03:59 +0530
> Naresh Kumar Inna <naresh@chelsio.com> wrote:
> 
>> +
>> +#define	CSIO_ASSERT(cond)						\
>> +do {									\
>> +	if (unlikely(!((cond))))					\
>> +		BUG();                                                  \
>> +} while (0)
>> +
> 
> Why is this not just BUG_ON(!(cond)) ?
> 

I will replace the 2 lines in the macro with BUG_ON() as you have
suggested. Thanks.
