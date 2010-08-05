From: Ben Greear <greearb@candelatech.com>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free (after
 using openvpn)
Date: Thu, 05 Aug 2010 09:57:14 -0700
Message-ID: <4C5AED6A.8040602@candelatech.com>
References: <loom.20100708T183152-326@post.gmane.org>	<20100709235744.GA12752@kroah.com>	<20100710101540.2799c9ef@xenia.leun.net>	<20100710140800.GA20424@kroah.com>	<20100710165208.59272ae6@xenia.leun.net>	<20100710235323.5336f627@xenia.leun.net>	<20100711192939.1c25dcaf@xenia.leun.net>	<20100804153543.56f6ecad@xenia.leun.net>	<20100804214618.GA6289@kroah.com>	<20100805001105.5a3453ed@xenia.leun.net>	<m1lj8l29zm.fsf@fess.ebiederm.org>	<20100805112538.60a46cb1@xenia.leun.net> <m1y6clz8ta.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Leun <lkml20100708@newton.leun.net>,
	Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1y6clz8ta.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/05/2010 02:51 AM, Eric W. Biederman wrote:
> Michael Leun<lkml20100708@newton.leun.net>  writes:

>> Unfortunately looks like indefinitely. Never watched longer so far
>> (rebooted soon), but I'm seeing this message now repeated every 10 secs
>> for ~10 minutes on a idle system.
>
> Ugh.  A real bug then.  These can be a pain to track down and fix. I
> think the last one of these I tracked down took a couple of weeks.  I
> will start digging in when I get back from vacation.

I once spent a similar amount of time putting in debug variants that
printed info for each time a netdev was acquired and released.

Maybe a similar logic could be put into the official kernel (and
disabled by default)?

That should save effort in the long run, I'd think.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
