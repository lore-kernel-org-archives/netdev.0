From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 04/11] rocker: add pipeline model for rocker
 switch
Date: Sun, 04 Jan 2015 21:18:41 -0800
Message-ID: <54AA1EB1.3060300@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194709.31070.16657.stgit@nitbit.x32> <CAJ3xEMitO-e4gRXAzp7F5F+1+Sq9+K8qQgTjEywA-FbX34bZ+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, sfeldma@gmail.com,
	=?UTF-8?B?SmnFmcOtIFDDrQ==?= =?UTF-8?B?cmtv?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:41757 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbAEFS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 00:18:56 -0500
Received: by mail-oi0-f49.google.com with SMTP id a141so45883381oig.8
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 21:18:56 -0800 (PST)
In-Reply-To: <CAJ3xEMitO-e4gRXAzp7F5F+1+Sq9+K8qQgTjEywA-FbX34bZ+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2015 12:43 AM, Or Gerlitz wrote:
> On Wed, Dec 31, 2014 at 9:47 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> This adds rocker support for the net_flow_get_* operations. With this
>> we can interrogate rocker.
>>
>> Here we see that for static configurations enabling the get operations
>> is simply a matter of defining a pipeline model and returning the
>> structures for the core infrastructure to encapsulate into netlink
>> messages.
>
> [..]
>

[...]

>> +
>
> John,
>
> Repeating the feedback I provided you f2f in Dusseldorf when the WIP
> code was within ixgbe, some/many code pieces in this patch (e.g the
> above) are generic and hence should reside not within a low level
> driver such as rocker, and also on a separate patch.
>
> Or.
>

yep... will address in v2 thanks for the reminder, I expect I'll have
a v2 ready some time soon.

-- 
John Fastabend         Intel Corporation
