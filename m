From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: [ipv4:PATCH] Allow userspace to specify primary or secondary ip
 on interface
Date: Mon, 30 Sep 2013 11:04:47 -0700
Message-ID: <CAK3+h2yNG72AKeOrTfvp_x8Zh5JHALFczcNz_VsuU9jjJatPbg@mail.gmail.com>
References: <1380056988-6717-1-git-send-email-vincent.mc.li@gmail.com>
	<20130929.175936.607666065014569193.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130929.175936.607666065014569193.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, I found I can use 'ip route replace' command to change the 'src'
address as workaround. Julian also responded in another thread that He
could come up with a patch to sort ip with scope, primary, secondary
preferences.

https://lkml.org/lkml/2013/9/27/482

Vincent

On Sun, Sep 29, 2013 at 2:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Vincent Li <vincent.mc.li@gmail.com>
> Date: Tue, 24 Sep 2013 14:09:48 -0700
>
>> the reason for this patch is that we have a multi blade cluster platform
>> sharing 'floating management ip' and also that each blade has its own
>> management ip on the management interface, so whichever blade in the
>> cluster becomes primary blade, the 'floating mangaement ip' follows it,
>> and we want any of our traffic originated from the primary blade source from
>> the 'floating management ip' for consistency. but in this case, since the local
>> blade management ip is always the primary ip on the mangaement interface and
>> 'floating management ip' is always secondary, kernel always choose the primary
>> ip as source ip address. thus we would like to add the flexibility in kernel to
>> allow us to specify which ip to be primary or secondary.
>
> You have the flexibility already.
>
> You can specify a specific source address ot use in routes.
