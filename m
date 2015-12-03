From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next v2 4/6] mlxsw: core: Implement temperature hwmon interface
Date: Thu, 3 Dec 2015 11:32:04 +0200
Message-ID: <CAJ3xEMhSPt7LW=cfCrQJ20u12p-bNGzkk8YpzN7yNHSSG-d6nA@mail.gmail.com>
References: <20151202222551.GP2355@nanopsycho.orion>
	<20151202.172847.1855287186918935450.davem@davemloft.net>
	<20151202223531.GQ2355@nanopsycho.orion>
	<20151202.183758.91764299340813651.davem@davemloft.net>
	<20151203081931.GA2331@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:33822 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932490AbbLCJcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 04:32:05 -0500
Received: by igvg19 with SMTP id g19so8990696igv.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 01:32:04 -0800 (PST)
In-Reply-To: <20151203081931.GA2331@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 10:19 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Dec 03, 2015 at 12:37:58AM CET, davem@davemloft.net wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Wed, 2 Dec 2015 23:35:31 +0100
>>
>>> Why to continue to work if we know that we are making things wrong
>>> (incorrect structure initialization in this case) ? What am I missing?
>>
>>The user might be able to continue to have connectivity and
>>report the problem.
>>
>>BUG_ON() is really a hard hammer.
>
> Okay.

So we are  removing this as well, right?

Or.
