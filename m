From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature
 flag for switch device offloads
Date: Fri, 05 Dec 2014 07:50:53 -0500
Message-ID: <5481AA2D.2090901@mojatatu.com>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com> <54819FDA.2030405@mojatatu.com> <20141205121730.GK1866@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, sfeldma@gmail.com, bcrl@kvack.org,
	tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:51459 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbaLEMu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 07:50:56 -0500
Received: by mail-ie0-f175.google.com with SMTP id x19so606747ier.34
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 04:50:56 -0800 (PST)
In-Reply-To: <20141205121730.GK1866@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/14 07:17, Jiri Pirko wrote:
> Fri, Dec 05, 2014 at 01:06:50PM CET, jhs@mojatatu.com wrote:
>> On 12/04/14 21:26, roopa@cumulusnetworks.com wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This is a generic high level feature flag for all switch asic features today.
>>>
>>> switch drivers set this flag on switch ports. Logical devices like
>>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>>>
>>> I had to use SWITCH in the name to avoid ambiguity with other feature
>>> flags. But, since i have been harping about not calling it 'switch',
>>> I am welcome to any suggestions :)
>>>
>>
>> I know  in this use case it is a switch. But please dont use that term
>> for things that we are going to use as generic offload descriptors.
>> How about just simple: NETIF_F_HW_DEV_OFFLOAD_BIT
>
> What that should tell it stands for? I think we need something more
> specific.
>

Ok, the use case in this instance is very specific. My blinders
go off anytime i see switch or sw or swdev.
In which case maybe what Scott suggested but changing L2FWD
with FDB?

cheers,
jamal
