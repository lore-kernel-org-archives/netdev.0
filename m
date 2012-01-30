From: Shriram Rajagopalan <rshriram@cs.ubc.ca>
Subject: Re: [PATCH V2] net/sched: sch_plug - Queue traffic until an explicit release command
Date: Mon, 30 Jan 2012 08:47:45 -0800
Message-ID: <B99410E5-6E69-425A-913D-272058765A68@cs.ubc.ca>
References: <1327823619-29274-1-git-send-email-rshriram@cs.ubc.ca> <1327934756.2243.3.camel@mojatatu> <313929ea4dca3c8fd6948797e03121a8@localhost>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Brendan Cully <brendan@cs.ubc.ca>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:33345 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861Ab2A3Qrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 11:47:52 -0500
Received: by vcbgb30 with SMTP id gb30so2832219vcb.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 08:47:51 -0800 (PST)
In-Reply-To: <313929ea4dca3c8fd6948797e03121a8@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-01-30, at 6:54 AM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> 
> On Mon, 30 Jan 2012 09:45:56 -0500, Jamal Hadi Salim wrote:
> 
>> Please address the comment from Hagen on the printk (kill it).
>> Other than that i think this simple enough and non-intrusive
>> to other users that you can add an Acked-by from me.
>> It will be nice to get it to be generic as per Hagen's and my
>> earlier comments.
> 
> I thought about sch_plug a second time and I like the idea of a user-space
> based flow-controlled queue. But as I wrote in my first email: the current
> implementation is a little bit XEN specific. Make it more general
> (plug/unplug

The use case I cited in the kconfig was xen specific. 
The plug and unplug functionality is already there and is generic.

I can certainly rename the tcq #defs :)

> , plug/packet-based-unplug) and it is a great contribution.
> 

Could you elaborate a little on the packet-based-unplug ?

I got your earlier comment on "indefinite unplug" until an explicit
plug is received. Is that what you mean by packet-based-unplug ?


Shriram
> Hagen
> 
