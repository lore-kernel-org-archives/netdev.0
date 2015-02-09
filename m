From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Mon, 09 Feb 2015 08:38:36 -0800
Message-ID: <54D8E28C.1000405@cumulusnetworks.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <54D3F8F9.2060500@cumulusnetworks.com> <54D424BD.2090402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	hannes@stressinduktion.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:38132 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760926AbbBIQik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 11:38:40 -0500
Received: by pdbft15 with SMTP id ft15so32163550pdb.5
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 08:38:40 -0800 (PST)
In-Reply-To: <54D424BD.2090402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15, 6:19 PM, David Ahern wrote:
> On 2/5/15 4:12 PM, roopa wrote:
>> Wondering if you have thought about some of the the below cases in your
>> approach to vrfs ?.
>> - Leaking routes from one vrf to another
>
> Can you give me an example of what you mean by this?

sorry for the delay in my response.
I cant say I know a lot about types of vrfs and vrf route leaking today :).
Hoping that i will catch up someday ;)

But I think it is needed to deploy VRF-lite (when MPLS is not in the 
picture).
And there maybe a need to leak routes from one VRF to another.
And the leaking can be done with static routes or dynamic using a 
routing protocol
I think (lot of content on the web for vrf route leaking).

I have been in discussions where namespaces are considered for vrfs..
and on the same lines as above there have been discussions on
  having the ability to add a route in one vrf with nexthop in another vrf
>
>> - route lookup in one vrf on failure to fallback to the global vrf (This
>> for example can be done using throw if we used ip rules and route tables
>> to do the same).
>> - A route in one vrf pointing to a nexthop in another vrf
>
> I have been more focused on the initial VRF infrastructure and have 
> not spent too much time on these use cases or other route lookup 
> features (e.g., allow an application to handle route lookup misses 
> similar to arp misses, allow custom route lookup modules) that are 
> needed to approach the feature richness provided by high end routers.
agreed. Thanks for opening up the vrf discussion!.
It will be good to consider all types of vrf deployments with any vrf 
solution we consider for the kernel.


Thanks,
Roopa
