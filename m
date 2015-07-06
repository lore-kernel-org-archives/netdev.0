From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: Re: [RFC net-next 0/6] Proposal for VRF-lite - v2
Date: Mon, 6 Jul 2015 10:53:33 -0700
Message-ID: <CAJmoNQHFxgfEqgZUWFdR_WzemBqGctWgKUez2H9956M0pLLaUg@mail.gmail.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
	<559AA187.6000007@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jon Toppins <jtoppins@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37065 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbbGFRxe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 13:53:34 -0400
Received: by wiclp1 with SMTP id lp1so28523770wic.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 10:53:33 -0700 (PDT)
In-Reply-To: <559AA187.6000007@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No no problem,

Just trying to get the functional aspects worked out. the global
search replace will be easy.

Was hoping to see some more responses on the naming suggestions here
from the community. If there is not disagreement we can spin patches
with MRF as the name.


On Mon, Jul 6, 2015 at 8:40 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 06/07/2015 17:03, David Ahern a =C3=A9crit :
>>
>> In the context of internet scale routing a requirement that always
>> comes up is the need to partition the available routing tables into
>> disjoint routing planes. A specific use case is the multi-tenancy
>> problem where each tenant has their own unique routing tables and in
>> the very least need different default gateways.
>>
>> This is an attempt to build the ability to create virtual router
>> domains aka VRF's (VRF-lite to be specific) in the linux packet
>> forwarding stack. The main observation is that through the use of
>> rules and socket binding to interfaces, all the facilities that we
>> need are already present in the infrastructure. What is missing is a
>> handle that identifies a routing domain and can be used to gather
>> applicable rules/tables and uniqify neighbor selection. The scheme
>> used needs to preserves the notions of ECMP, and general routing
>> principles.
>
> [snip]
>>
>>   drivers/net/vrf.c             | 486
>> ++++++++++++++++++++++++++++++++++++++++++
>
> [snip]
>
> I'm still opposed to name this 'vrf', see the v1 thread:
>  - http://www.spinics.net/lists/netdev/msg332357.html
>  - http://www.spinics.net/lists/netdev/msg332376.html
>
> Shrijeet seemed to agree to rename it, is there a problem?
>
>
> Regards,
> Nicolas
