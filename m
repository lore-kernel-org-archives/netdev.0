From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/1] iproute2 bridge: bring to par with brctl show macs
Date: Tue, 27 May 2014 16:40:10 -0700
Message-ID: <5385225A.5020402@cumulusnetworks.com>
References: <1401024151-8774-1-git-send-email-jhs@emojatatu.com> <27A51C19-553E-4BA0-A8B2-F4251FABA5F4@cumulusnetworks.com> <53850672.1030107@mojatatu.com> <5385070F.1030802@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>, john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:39629 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbaE0XkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 19:40:13 -0400
In-Reply-To: <5385070F.1030802@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/27/14, 2:43 PM, Jamal Hadi Salim wrote:
> On 05/27/14 17:41, Jamal Hadi Salim wrote:
>
>> filtering by brport is very useful.
>> I wasnt as much concerned about that use case because i can already
>> filter in user space for brport when i dump (iproute2 does as well).
>> But i couldnt filter by bridge since that info is not even
>> present in the dumped data
>> I just saw the patch posted by Roopa - I think that now gives me the
>> ability to also filter by bridge in user space.
>>
>> Note: All i am doing is stealing the ndm ifindex - which before was
>> a zero and ignore by the kernel as the bridge ifindex.
>> I think what you are suggesting is: if the user doesnt specify the
>> bridge i should use the ndm ifindex to send down the brport as
>> the filter. But that becomes an bridge "or" bridgeport filter
>> choice. A more useful scenario is to have bridge "and"
>> bridgeport filter. So almost seems like i need an attribute to send
>> down for the bridge port.
>> Sounds like a separate patch...
>>
>
> Hrm. I wonder - I could use the NDA_MASTER attribute that Roopa
> posted to define the bridge filter. I could then use the ndm ifindex to
> define the bridgeport filter.
>
> Thoughts?
>
I was just going to suggest that. ifindex is used for ports during 
notify as well. so, might makes sense to use ndm_ifindex for ports 
during dump.
