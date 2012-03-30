From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] macvlan: add FDB bridge ops
Date: Thu, 29 Mar 2012 18:06:25 -0700
Message-ID: <4F750711.2060508@intel.com>
References: <CB9A2187.4A989%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48530 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753846Ab2C3BG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 21:06:26 -0400
In-Reply-To: <CB9A2187.4A989%roprabhu@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/29/2012 2:26 PM, Roopa Prabhu wrote:
> 
> 
> 
> On 3/28/12 8:58 AM, "John Fastabend" <john.r.fastabend@intel.com> wrote:
> 
>> On 3/28/2012 8:52 AM, Michael S. Tsirkin wrote:
>>> On Wed, Mar 28, 2012 at 08:43:56AM -0700, Roopa Prabhu wrote:
>>>> On 3/20/12 5:26 PM, "John Fastabend" <john.r.fastabend@intel.com> wrote:
>>>>
>>>>> Add support to add/del and dump the forwarding database
>>>>> for macvlan passthru mode. The macvlan driver acts like
>>>>> a Two Port Mac Relay (TPMR 802.1Q-2011) in the passthru
>>>>> case so adding forwarding rules is just adding the addr
>>>>> to the uc or mc lists.
>>>>>

[...]

>>>
>>>
>>> So this clears the promisc on the first add which
>>> is a bit annoying. How about a simple flag, set when
>>> we create the macvlan?
>>>
>>
>> Agreed. This probably needs a new attrib maybe IFLA_MACVLAN_FLAGS unless
>> there already exists a per "kind" (rtnl_link_ops) flags field we can use.
>> I scanned the code briefly and didn't see any such thing so likely we need
>> the new attribute.
> 
> O ok. That makes sense. Unfortunately I am not sure if I will be able to get
> back to this anytime in the near future. If anyone wants to rework this
> patch please do.
> 
> Thanks.
> Roopa
>  
> 

OK I'll fix it up and submit it with the rest of the FDB
patches.

.John
