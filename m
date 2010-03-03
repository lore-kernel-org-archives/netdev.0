From: Tejun Heo <tj@kernel.org>
Subject: Re: 2.6.33 problems
Date: Wed, 03 Mar 2010 09:56:45 +0900
Message-ID: <4B8DB3CD.6050204@kernel.org>
References: <1267290551.13148@guyane.dyn-o-saur.com> <20100302135032.e3d11bbf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: werner@guyane.dyn-o-saur.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100302135032.e3d11bbf.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 03/03/2010 06:50 AM, Andrew Morton wrote:
> On Sat, 27 Feb 2010 14:09:11 -0300 (GFT)
> werner@guyane.dyn-o-saur.com wrote:
> 
>> For better error searching / correction, I add below the whole syslog.
>>
>> This is refered to 2.6.33  published (without patchs)
>>
>> This are different errors.
>>
>> The most of them exists since 2.6.33-rc1 or appr. -rc5.
>>
>> I posted here already the whole syslog.bz2 but nobody toke care.
>>
>> the boot_vga error occurs only after I start the grafics mode.  It's the mainboard's embedded nvidia grafics. I use the vesa framebuffer driver of X 1.8
>>
>> the int6_init error occurs also in text mode. I think it have something to do with internet.
>>
>> Also the printk errors occur only when start the computer in the grafics mode, but not when starting it in the text mode.
>>
>> Below is also the kernel config. Its the same like since -rc7 (but the errors are also the same)

Hmmmm... it seems like the percpu allocator failed to allocate space
for a new chunk in the vmalloc area.  Looking through the config.
Hmmm, w/ 3G split, there should be enough vmalloc area.  Strange.
Does kernel parameter "percpu_alloc=page" make the machine boot?  If
so, can you please post the output of dmesg right after boot?

Thanks.

-- 
tejun
