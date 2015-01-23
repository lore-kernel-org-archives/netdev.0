From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 1/5] netdev: introduce new NETIF_F_HW_NETFUNC_OFFLOAD
 feature flag for switch device offloads
Date: Fri, 23 Jan 2015 15:09:00 -0800
Message-ID: <54C2D48C.5090706@cumulusnetworks.com>
References: <1421987606-10884-2-git-send-email-roopa@cumulusnetworks.com> <20150123094459.GA2065@nanopsycho.orion> <54C26D4C.9050407@cumulusnetworks.com> <20150123175654.GB25374@casper.infradead.org> <20150123190518.GP2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:49311 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbbAWXJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 18:09:02 -0500
Received: by mail-pd0-f176.google.com with SMTP id y10so257963pdj.7
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 15:09:01 -0800 (PST)
In-Reply-To: <20150123190518.GP2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/15, 11:05 AM, Jiri Pirko wrote:
> Fri, Jan 23, 2015 at 06:56:54PM CET, tgraf@suug.ch wrote:
>> On 01/23/15 at 07:48am, roopa wrote:
>>> On 1/23/15, 1:44 AM, Jiri Pirko wrote:
>>>> How about rather "HW_DATAPATH_OFFLOAD"? Feels more accurate. By the
>>>> name, I still cannot understand what NETFUNC should mean.
>>> It was supposed to mean 'network function offload'. sure, will consider
>>> HW_DATAPATH_OFFLOAD
>>> or if anybody has other suggestions.
>> I'm still fascinated that the description says 'for all switch asic
>> offloads', 'switch drivers', 'switch ports' but we try very hard to
>> come up with a different name ;-)
> +1
> But we'll see in future. I bet that "switch" will stick.
because....am sure anything else will get rejected  ;).

...The API/patches is currently targeting switch ASIC devices but the 
idea behind having the flag
not be called 'switch' was to cover all the devices being discussed 
today (previous threads on this indicate that).

Its fair to say that I only care about switch asics today. If that's the 
popular vote i am going with that.

renaming it in the next series...
