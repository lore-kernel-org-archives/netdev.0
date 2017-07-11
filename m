From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: Re: [PATCH] net: chelsio: cxgb3: constify attribute_group structures.
Date: Tue, 11 Jul 2017 11:23:38 +0530
Message-ID: <49d4a885-5b27-35a5-be2d-08d5a483429b@gmail.com>
References: <0e68326e48e123c70191169a0c0da820237425ec.1499682619.git.arvind.yadav.cs@gmail.com>
 <1499706011.5468.15.camel@perches.com>
 <8884bd80-b8d5-1c1e-5235-b0a0c173bc45@gmail.com>
 <1499752060.4457.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, santosh@chelsio.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499752060.4457.8.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,


On Tuesday 11 July 2017 11:17 AM, Joe Perches wrote:
> On Tue, 2017-07-11 at 11:11 +0530, Arvind Yadav wrote:
>> Hi Joe,
>>
>>
>> On Monday 10 July 2017 10:30 PM, Joe Perches wrote:
>>> On Mon, 2017-07-10 at 16:04 +0530, Arvind Yadav wrote:
>>>> attribute_groups are not supposed to change at runtime. All functions
>>>> working with attribute_groups provided by <linux/sysfs.h> work
>>>> with const attribute_group. So mark the non-const structs as const.
>>> I think it's good you are doing all of these.
>>>
>>> Instead of individually sending these patches, could you
>>> please send a patch series for all of these attribute_group
>>> patches with a cover letter at the same time?
>>>
>>> That could make it easier for a trivial maintainer to apply
>>> all of these at once and not get some applied and others
>>> ignored or dropped on the floor.
>>>
>> Once again, I will send all of patch together, But I have doubt. If it's
>> having
>> different maintainer. Example- 'net:' subsystem is having a different
>> different
>> maintainer. So do i need to add all the maintainer in single list. Which
>> can confuse
>> what patch is for what maintainer. Please suggest me.
> Please send individual patches, one per maintainer/subsystem
> as a series with a cover letter like:
>
> 	[PATCH 0/N] treewide: constify attribute_group structures
> 	[PATCH 1/N] chelsio: cxgb3: constify attribute_group
> 	[PATCH 2/N] chelsio: cxgb4: constify attribute_group
> 	...
> 	[PATCH N/N] subsystem: constify attribute_group
>
Thank you, I will follow as per your suggestion.

Regards,
~arvind
