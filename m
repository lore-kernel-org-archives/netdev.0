From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH ipsec-next 2/2] xfrm: configure policy hash table thresholds
 by /proc
Date: Fri, 23 May 2014 10:30:13 +0200
Message-ID: <537F0715.7010207@6wind.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com> <1399902325-1788-3-git-send-email-christophe.gouault@6wind.com> <20140515083447.GC32371@secunet.com> <5379B591.6020001@6wind.com> <20140522100905.GH32371@secunet.com> <063D6719AE5E284EB5DD2968C1650D6D1724B7DA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Steffen Klassert' <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:63154 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbaEWIaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 04:30:17 -0400
Received: by mail-we0-f181.google.com with SMTP id w61so4619810wes.12
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 01:30:15 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724B7DA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2014 12:15 PM, David Laight wrote:
> From: Klassert
> ...
>>> Exporting a userland API (here by /proc) enables a user or a daemon to
>>> choose a strategy according to information the kernel does not
>>> necessarily have, and enables to implement various (possibly complex)
>>> policies.
>>>
>>
>> If we add a user API for the current lookup mechanism, we will stick
>> with this because we can't change it anymore without breaking userspace.
>> So I don't want to add one before we finally decided on a long term
>> lookup mechanism for IPsec.
>
> You could have a user API call to find the list of available mechanisms
> as well as one that returns/sets the current one.
> Then there is no actual requirement to continue to support any specific one.
>
> 	David

Hi David,

It sounds like a brilliant idea, since we will probably need to support
several types of mechanisms. If nobody objects, I can start working on
such API.

Any preference on the type of API? (/proc, netlink, ioctl?...)

Christophe
