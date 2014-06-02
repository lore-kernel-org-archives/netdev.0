From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v2] net: tunnels - enable module autoloading
Date: Mon, 2 Jun 2014 20:57:02 +0200
Message-ID: <CAG-2HqUEqz26YMTDHNVHUEtWDcaVrq3EKX-e8-9wnm4Y1XCUag@mail.gmail.com>
References: <20140515.153721.2222505094570361361.davem@davemloft.net>
 <1400188890-2038-1-git-send-email-teg@jklm.no> <20140521.154744.124910385161203311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140521.154744.124910385161203311.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 21, 2014 at 9:47 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Gundersen <teg@jklm.no>
> Date: Thu, 15 May 2014 23:21:30 +0200
>
>> Enable the module alias hookup to allow tunnel modules to be autoloaded on demand.
>>
>> This is in line with how most other netdev kinds work, and will allow userspace
>> to create tunnels without having CAP_SYS_MODULE.
>>
>> Signed-off-by: Tom Gundersen <teg@jklm.no>
>> ---
>> v2: add ';'
>>
>> Hi Dave,
>>
>> I must have sent out the wrong version of this patch. Sorry for the inconvenience!
>
> Applied to net-next

Thanks!

> although I never saw a firm conclusion in the
> thread for the original patch where there was a discussion about
> whether this is already possible or not.

It is my understanding that this is not already possible, which is why
the MODULE_ALIAS_RTNL_LINK exists.

Would this patch be suitable for stable? While it does not fix a
regression, it appears to fix the intended behaviour of
MODULE_ALIAS_RTNL_LINK?

What I'll do in userspace is to drop CAP_SYS_MODULE and just tell
people who want tunnels to wait for a new kernel (or backport the
patch), but having it in stable would obviously make it simpler.

Cheers,

Tom
