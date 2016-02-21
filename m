From: Diego Viola <diego.viola@gmail.com>
Subject: Re: [PATCH] jme: remove the jme driver as it is no longer maintained
Date: Sun, 21 Feb 2016 14:17:23 -0300
Message-ID: <CA+ToGPEQwdOvgN3OHEjHLrnAyQsCR7zHzvtHmYeKZzoq26ehjQ@mail.gmail.com>
References: <1456003203-10863-1-git-send-email-diego.viola@gmail.com>
	<20160220.191659.1399118945067159430.davem@davemloft.net>
	<CA+ToGPEZoe3tnJQHNYED1bxSGrcdZP+AyQHjv==pMovwqYniig@mail.gmail.com>
	<20160221124506.00237916@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, cooldavid@cooldavid.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160221124506.00237916@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 21, 2016 at 9:45 AM, One Thousand Gnomes
<gnomes@lxorguk.ukuu.org.uk> wrote:
>> I would appreciate some hint from someone who is more experienced with drivers.
>
> Start by testing
>
> - loading the driver as a module
> - using the networking
> - unloading the module (and checking it stays unloaded!)
>
> then suspend/resume
>
> If that works then you have a good starting point because you know a
> sequence of actions that suspends properly. If it fails then it's going
> to be rather more fun because it implies something in the hardware has
> not been properly shut down.
>
> Alan

Hi Alan,

Thanks for your email, did you see my bug report? Because I tried all
this already.

The only workarounds I've found to work is one of these:

$ rmmod jme # before suspend

or

$ ip link set ens34 down

or

$ echo 0 > /sys/power/pm_async # disable async power management

Then resume works fine (I can't reproduce the hang).

I'm not a C developer nor a kernel developer, I tried looking at the
jme.c driver code but it's not clear what is broken and what needs
fixing, so I would appreciate someone more experienced looking at the
issue and giving me an idea or two.

Thanks,
Diego
