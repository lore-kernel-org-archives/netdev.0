From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] netdev: generate kobject uevent on network state transitions
Date: Wed, 26 Nov 2008 06:24:47 +0100
Message-ID: <FB30A309-CE17-43E7-8B5B-BC276E849720@holtmann.org>
References: <20081124150347.73050f98@extreme> <AAE2573A-3C23-4C61-89E1-3A6F31D7B23E@holtmann.org> <20081124201440.0e4d61cc@extreme> <20081125.010943.205685748.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bhutchings@solarflare.com,
	kay.sievers@vrfy.org, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20081125.010943.205685748.davem@davemloft.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

>>>> It is easier for some applications to deal with text based  
>>>> interfaces
>>>> like uevent, rather than using netlink to listen for events.
>>>>
>>>> Note, this does not deal with network namespaces but that is a  
>>>> generic
>>>> problem that already exists with kobjects (see rename events).
>>>>
>>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ...
>>> do we wanna copy just what ifconfig shows or do we might be a more
>>> intelligent and have separate variables like RUNNING=1 etc.?
>>
>> Was arbitrary choice to just use same flags as existing ifconfig.
>> What ever feels best I guess...
>
> So what do folks want me to do here?  Should I put Stephen's
> latest patch in, or do we want to make some kind of flags change?

I am thinking of using per value variables. My personal choice.

Kay, any pointers or opinions from you?

Regards

Marcel

