From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sysfs: Report link speed only when possible
Date: Mon, 16 Jun 2014 01:44:30 -0700 (PDT)
Message-ID: <20140616.014430.163976160998454211.davem@davemloft.net>
References: <539E9D93.9040405@redhat.com>
	<20140616.011148.2001285440663327901.davem@davemloft.net>
	<539EAB23.3020101@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mprivozn@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <539EAB23.3020101@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Privoznik <mprivozn@redhat.com>
Date: Mon, 16 Jun 2014 10:30:27 +0200

> On 16.06.2014 10:11, David Miller wrote:
>> From: Michal Privoznik <mprivozn@redhat.com>
>> Date: Mon, 16 Jun 2014 09:32:35 +0200
>>
>>> On 13.06.2014 22:03, David Miller wrote:
>>>> From: Michal Privoznik <mprivozn@redhat.com>
>>>> Date: Fri, 13 Jun 2014 11:19:51 +0200
>>>>
>>>>> So if I were developing brand new application I could say: I'm
>>>>> dropping all this workaround code and have it clean and require say
>>>>> 3.16 kernel at least.
>>>>
>>>> Then your application wouldn't be usable on %99 of systems for a long
>>>> long time.
>>>>
>>>
>>> How come? The application is going to be usable for as long as
>>> library/kernel APIs won't change.
>>
>> Because %99 of users are using a distribution kernel which is
>> definitely
>> going to be pre-3.16 for years.
>>
> 
> That's why every distribution out there has a mechanism to install
> packages of a certain version, or those providing certain symbol,
> whatever. Or distributions can then backport some kernel patches or
> something. But, that's completely unrelated to the problem I'm fixing
> here. I don't think this bikeshedding is useful for anything, sorry.

You're being entirely impractical.

By restricting an application to a kernel version or behavior "via
backported patches" which doesn't even exist yet, you are foolishly
restricting your userbase.

People just cope with what the current kernels support, when possible,
and that's the right thing to do because we cannot break it on them
exactly because people can depend upon the behavior.

NOBODY is checking for -EINVAL returns when reading the link speed
sysfs file, and therefore by signalling it you will break
applications.

So I will not apply a patch which adds that new behavior, sorry.

I am not willing to discuss this further, this is fundamental and
simple as far as I'm concerned.
