From: David Ranch <linux-hams@trinnet.net>
Subject: Re: [PATCH v3 0/2] refactor code and mark expected switch
 fall-throughs
Date: Sat, 28 Oct 2017 21:15:45 -0700
Message-ID: <f0f38830-badd-1859-a9ba-5ac5452f8847@trinnet.net>
References: <b0e6de21-b258-dc78-4710-a61b81ec419c@trinnet.net>
 <20171027144853.Horde.ExzHfROE4gaCiHalihXFClP@gator4166.hostgator.com>
 <e5c376f0-fdd0-78a7-a40f-0b990cff0023@trinnet.net>
 <20171029.104541.1487088453362795756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: garsilva@embeddedor.com, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, ralf@linux-mips.org, wharms@bfs.de,
        hal@kd.net.au, f6bvp@free.fr, thomas@osterried.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.trinnet.net ([69.12.138.16]:61260 "EHLO
        trinity.trinnet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdJ2EPr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 00:15:47 -0400
In-Reply-To: <20171029.104541.1487088453362795756.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello David,

Thanks for the reply.  I completely admit that there aren't many changes 
going into this section of code.  Unfortunately, we've had some nasty 
breaks that took quite a long while to get fixed.

Can you point me in the direction of this kbuild test robot (URLs, etc) 
so I can better understand if it makes sense to add tests there?  For 
example, do you know if it's "changed based" so only certain tests will 
run if given files are updated?

--David
KI6ZHD


On 10/28/2017 06:45 PM, David Miller wrote:
> From: David Ranch <linux-hams@trinnet.net>
> Date: Sat, 28 Oct 2017 10:53:24 -0700
>
>> Does anyone else have thoughts on this topic?
>
> I think you are making a mountain out of a mole hill.
>
> If you care so much about this, set things up so that entities such as
> the kbuild test robot run whatever tests you think are necessary.
>
> Otherwise, continually test the stack yourself and report any
> regressions here as fast as you can.
>
> If soemone can't be bothered to verify or test someone's change in 2
> or 3 days, except in extreme circumstances, I absolutely refuse to
> burdon the submitter and let their patches rot in the queue.
>
> That's unacceptable.
>
> That's the proper way to deal with this, without unreasonably
> burdoning people who just want to keep the code across the tree modern
> and more up to date.
>
> Thank you.
