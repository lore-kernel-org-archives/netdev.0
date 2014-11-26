From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: add vlan id to mdb notifications
Date: Wed, 26 Nov 2014 12:45:20 -0800
Message-ID: <54763BE0.8000103@cumulusnetworks.com>
References: <1417010013-31454-1-git-send-email-roopa@cumulusnetworks.com> <20141126105614.6a42d697@urahara> <54762CB3.4090101@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	vyasevich@gmail.com, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com, gospo@cumulusnetworks.com,
	sashok@cumulusnetworks.com
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36949 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaKZUpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 15:45:24 -0500
In-Reply-To: <54762CB3.4090101@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14, 11:40 AM, Jonathan Toppins wrote:
> On 11/26/14 1:56 PM, Stephen Hemminger wrote:
>> On Wed, 26 Nov 2014 05:53:33 -0800
>> roopa@cumulusnetworks.com wrote:
>>
>>> diff --git a/include/uapi/linux/if_bridge.h 
>>> b/include/uapi/linux/if_bridge.h
>>> index da17e45..db061fd 100644
>>> --- a/include/uapi/linux/if_bridge.h
>>> +++ b/include/uapi/linux/if_bridge.h
>>> @@ -185,6 +185,7 @@ struct br_mdb_entry {
>>>               struct in6_addr ip6;
>>>           } u;
>>>           __be16        proto;
>>> +        __be16        vid;
>>>       } addr;
>>>   };
>>>
>>
>> You can't add fields to existing binary API
>>
>
> Roopa, maybe a description of what use case this is trying to solve 
> would better justify the addition to the UAPI?
>
I don't think a description of use case can be used to justify a UAPI 
breakage. Getting the patch out was mainly to see if this really breaks 
UAPI.
Basically to get some feedback.
