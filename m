From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 13/13] ipv6: route: per route IP tunnel
 metadata via lightweight tunnel
Date: Wed, 19 Aug 2015 22:15:33 -0700 (PDT)
Message-ID: <20150819.221533.1044691669375994723.davem@davemloft.net>
References: <55D45A0A.7010100@miraclelinux.com>
	<20150819123151.3802e8f3@griffin>
	<55D53B72.70403@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, tgraf@suug.ch
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbbHTFPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 01:15:36 -0400
In-Reply-To: <55D53B72.70403@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Date: Thu, 20 Aug 2015 11:29:06 +0900

> Jiri Benc wrote:
>> On Wed, 19 Aug 2015 19:27:22 +0900, YOSHIFUJI Hideaki wrote:
>>>> You're right generally. But this one should be okay and I did this
>>>> deliberately: the patch adding LWTUNNEL_ENCAP_ILA was merged two days
>>>> ago, is in net-next only, is not used by anything in user space yet.
>>>> And I think it's better to have LWTUNNEL_ENCAP_IP and
>>>> LWTUNNEL_ENCAP_IP6 without anything in between.
>>>
>>> I do think you should have some descriptions.
>> 
>> Sorry, I meant to put this into the description but forget to add it
>> after the rebase on top of ILA (as the patchset conflicted with the ILA
>> work and was developed in parallel).
>>
>> Are you okay with inserting LWTUNNEL_ENCAP_IP6 before
>> LWTUNNEL_ENCAP_ILA? If so, I'll resend with the explanation added.
> 
> Well, I think we should always avoid adding new entries into the
> middle of enums because it will make bisecting more complex or more
> difficult for example even if it *seems* that we have no users yet and
> the risk is not so high.
> 
> Dave?

Agreed.
