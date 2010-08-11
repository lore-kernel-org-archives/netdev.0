From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Fix 'addr flush secondary' logic.
Date: Wed, 11 Aug 2010 13:53:29 -0700
Message-ID: <4C630DC9.9030608@candelatech.com>
References: <1281547182-1252-1-git-send-email-greearb@candelatech.com> <4C630B0A.9010304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57009 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270Ab0HKUxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 16:53:31 -0400
In-Reply-To: <4C630B0A.9010304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/11/2010 01:41 PM, Brian Haley wrote:
> On 08/11/2010 01:19 PM, Ben Greear wrote:
>> @@ -648,7 +648,7 @@ int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
>>   {
>>   	struct ifaddrmsg *ifa = NLMSG_DATA(n);
>>
>> -	if (ifa->ifa_flags&  IFA_F_SECONDARY)
>> +	if (!ifa->ifa_flags&  IFA_F_SECONDARY)
>>   		return 0;
>
> Shouldn't this be:
>
> 	if (!(ifa->ifa_flags&  IFA_F_SECONDARY))

Yes, that looks like a bug.  Let me re-test to make sure
it wasn't hiding other bugs and will re-submit.

Thanks,
Ben

>
> -Brian


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

