From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH 0/2] bonding: couple of bug fixes
Date: Tue, 11 Jun 2013 18:50:00 +0200
Message-ID: <51B75538.1080102@redhat.com>
References: <1370519702-18581-1-git-send-email-nikolay@redhat.com> <20130611.024530.1458814488844049119.davem@davemloft.net> <30610.1370968934@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755228Ab3FKRF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 13:05:58 -0400
In-Reply-To: <30610.1370968934@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/13 18:42, Jay Vosburgh wrote:
> David Miller <davem@davemloft.net> wrote:
> 
>> From: nikolay@redhat.com
>> Date: Thu,  6 Jun 2013 13:55:00 +0200
>>
>>> From: Nikolay Aleksandrov <nikolay@redhat.com>
>>>
>>> Hello,
>>> Patch 01 resets the master's mac if the first enslave fails and the slave's
>>> mac was set to the master's prior.
>>> Patch 02 fixes a type bug of igmp_retrans (which is the counter of igmp_resend
>>> param and was silently not working if the value was >127) so it can go up to 255
>>> (as per documentation). It also fixes two tricky race conditions which were
>>> hidden because of the previous bug.
>>
>> There was some minor back and forth between Jay and Nikolay on this set,
>> but I'd like to see some ACKs before applying this stuff.
> 
> 	I'm fine with the code changes, although I think a description
> of the three way race that Nikolay described in his last email should be
> in the log message, perhaps along with a brief description of what
> conditions would trigger the problem.
> 
> 	With the above caveat:
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks for the review Jay.
Dave how would you like me to handle this ? Should I resubmit a v2 with
updated commit message or just a reply with new commit message will
suffice ?

Nik
