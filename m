From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: How to fix CHECK warning: testing a 'safe expression'
Date: Fri, 2 Jan 2015 09:51:25 -0500
Message-ID: <54A6B06D.50102@ti.com>
References: <54907884.2040502@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <josh@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54907884.2040502@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ Josh

On 12/16/2014 01:23 PM, Murali Karicheri wrote:
> netdev maintainers,
>
> I got a comment to address CHECK warning and wondering how to address
> 'warning: testing a 'safe expression' which appears when using
> IS_ERR_OR_NULL(foo)
>
> where foo is defined as
>
> struct foo_type *foo;
>
> The foo get assigned only NULL or ERR_PTR(error code). So I believe the
> usage is correct. But then how do I make the CHECK happy of its usage?
>
> I have tried doing a grep on the current usage of IS_ERR_OR_NULL() and
> found 276 of them causes this warning in the v3.18 version of the kernel
> that I am using
>
> $ grep -r "warning: testing a 'safe expression" * | wc -l
> 276
>
> 1) Can someone explain what this warning means?
>
> 2) Is it acceptable to post patches to netdev list with this warning?
>
> 3) if not, how this is expected to be fixed? Any example usage to fix
> this warning will be helpful.
>
> Thanks in advance for


-- 
Murali Karicheri
Linux Kernel, Texas Instruments
