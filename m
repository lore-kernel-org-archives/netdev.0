From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Thu, 05 Feb 2015 19:19:41 -0700
Message-ID: <54D424BD.2090402@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <54D3F8F9.2060500@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	hannes@stressinduktion.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34800 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbbBFCTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 21:19:43 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so4353021igq.0
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 18:19:42 -0800 (PST)
In-Reply-To: <54D3F8F9.2060500@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 4:12 PM, roopa wrote:
> Wondering if you have thought about some of the the below cases in your
> approach to vrfs ?.
> - Leaking routes from one vrf to another

Can you give me an example of what you mean by this?

> - route lookup in one vrf on failure to fallback to the global vrf (This
> for example can be done using throw if we used ip rules and route tables
> to do the same).
> - A route in one vrf pointing to a nexthop in another vrf

I have been more focused on the initial VRF infrastructure and have not 
spent too much time on these use cases or other route lookup features 
(e.g., allow an application to handle route lookup misses similar to arp 
misses, allow custom route lookup modules) that are needed to approach 
the feature richness provided by high end routers.

David
