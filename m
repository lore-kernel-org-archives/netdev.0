From: "J.A. Magallon" <jamagallon@able.es>
Subject: Re: [PATCH] kill massive wireless-related log spam
Date: Wed, 26 Oct 2005 23:23:58 +0200
Message-ID: <AB480DAC-57B0-4125-8BA5-D6C715B693B6@able.es>
References: <20051026042827.GA22836@havoc.gtf.org> <200510261704.15366.ak@suse.de> <9a8748490510260823s681a4d82k5efa5734486eda85@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v734)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964939AbVJZVYF@vger.kernel.org>
In-Reply-To: <9a8748490510260823s681a4d82k5efa5734486eda85@mail.gmail.com>
To: Linux-Kernel <linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2005.10.26, at 17:23, Jesper Juhl wrote:

> On 10/26/05, Andi Kleen <ak@suse.de> wrote:
>
>> On Wednesday 26 October 2005 06:28, Jeff Garzik wrote:
>>
>>
>>> Change this to printing out the message once, per kernel boot.
>>>
>>
>> It doesn't do that. It prints it once every 2^32 calls. Also
>>
>
> I noted that as well. How about just using something along the  
> lines of
>
> static unsigned char printed_message = 0;
> if (!printed_message) {
>     printk(...);
>     printed_message++;
> }

Sorry, but why not the old good

     printed_message = 1

??
What kind of microoptimization is that ?

--
J.A. Magallon <jamagallon()able!es>   \          Software is like sex:
wolverine                              \    It's better when it's free
MacOS X 10.4.2, Darwin Kernel Version 8.2.0
