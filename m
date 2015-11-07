From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Fri, 6 Nov 2015 17:24:36 -0800
Message-ID: <563D52D4.2020607@roeck-us.net>
References: <1445437773-23261-1-git-send-email-linux@roeck-us.net>
 <20151021215320.GB23371@roeck-us.net> <20151106191652.GA4046@roeck-us.net>
 <3819536.piFndcizrV@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3819536.piFndcizrV@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/06/2015 12:30 PM, Arnd Bergmann wrote:
> On Friday 06 November 2015 11:16:52 Guenter Roeck wrote:
>> On Wed, Oct 21, 2015 at 02:53:20PM -0700, Guenter Roeck wrote:
>>> On Wed, Oct 21, 2015 at 09:11:53PM +0200, Arnd Bergmann wrote:
>>>> On Wednesday 21 October 2015 10:03:05 Guenter Roeck wrote:
>>>>> Anyway, if it gets that complicated, I think we should stick with
>>>>> just returning OF_BAD_ADDR. The above really suggests the need for
>>>>> an architecture specific solution.
>>>>
>>>> Probably no harm in this really: the far more common
>>>> of_address_to_resource() and of_iomap() helpers are equally
>>>> broken on SPARC and we just return a runtime error for those
>>>> as well without CONFIG_OF_ADDRESS rather than breaking the build.
>>>>
>>> Agreed. Given this, returning OF_BAD_ADDR sounds like a better choice.
>>>
>> Arnd,
>>
>> do you know if a fix for this problem is pending in some branch ?
>> Mainline sparc builds are now affected.
>>
>
> I don't think anyone wrote the patch to do this. Can you send one?
>

I'll see what I can do.

Guenter
