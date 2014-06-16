From: Michal Privoznik <mprivozn@redhat.com>
Subject: Re: [PATCH] net-sysfs: Report link speed only when possible
Date: Mon, 16 Jun 2014 10:30:27 +0200
Message-ID: <539EAB23.3020101@redhat.com>
References: <539AC237.40402@redhat.com>	<20140613.130350.1729507484821351177.davem@davemloft.net>	<539E9D93.9040405@redhat.com> <20140616.011148.2001285440663327901.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140616.011148.2001285440663327901.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16.06.2014 10:11, David Miller wrote:
> From: Michal Privoznik <mprivozn@redhat.com>
> Date: Mon, 16 Jun 2014 09:32:35 +0200
>
>> On 13.06.2014 22:03, David Miller wrote:
>>> From: Michal Privoznik <mprivozn@redhat.com>
>>> Date: Fri, 13 Jun 2014 11:19:51 +0200
>>>
>>>> So if I were developing brand new application I could say: I'm
>>>> dropping all this workaround code and have it clean and require say
>>>> 3.16 kernel at least.
>>>
>>> Then your application wouldn't be usable on %99 of systems for a long
>>> long time.
>>>
>>
>> How come? The application is going to be usable for as long as
>> library/kernel APIs won't change.
>
> Because %99 of users are using a distribution kernel which is definitely
> going to be pre-3.16 for years.
>

That's why every distribution out there has a mechanism to install 
packages of a certain version, or those providing certain symbol, 
whatever. Or distributions can then backport some kernel patches or 
something. But, that's completely unrelated to the problem I'm fixing 
here. I don't think this bikeshedding is useful for anything, sorry.

Michal
