From: Jim Cromie <jim.cromie@gmail.com>
Subject: Re: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Thu, 30 Aug 2012 21:48:12 -0600
Message-ID: <CAJfuBxyToA9-=c3H88GGba3GFX64kdbP4OCEC0f4trnBnjpU-w@mail.gmail.com>
References: <cover.1345978012.git.joe@perches.com> <CAJfuBxyQc-XeNHxw0_XDs0JuCrNArNzcgsmrLya4ncDvSojZxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@redhat.com>, Kay Sievers <kay@vrfy.org>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:61452 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab2HaDsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 23:48:43 -0400
In-Reply-To: <CAJfuBxyQc-XeNHxw0_XDs0JuCrNArNzcgsmrLya4ncDvSojZxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 30, 2012 at 11:43 AM, Jim Cromie <jim.cromie@gmail.com> wrote:
> On Sun, Aug 26, 2012 at 5:25 AM, Joe Perches <joe@perches.com> wrote:
>> The recent commit to fix dynamic_debug was a bit unclean.
>> Neaten the style for dynamic_debug.
>> Reduce the stack use of message logging that uses netdev_printk
>> Add utility functions dev_printk_emit and dev_vprintk_emit for /dev/kmsg.
>>
>> Joe Perches (5):
>>   dev_dbg/dynamic_debug: Update to use printk_emit, optimize stack
>>   netdev_printk/dynamic_netdev_dbg: Directly call printk_emit
>>   netdev_printk/netif_printk: Remove a superfluous logging colon
>>   dev: Add dev_vprintk_emit and dev_printk_emit
>>   device and dynamic_debug: Use dev_vprintk_emit and dev_printk_emit
>>
>
> Ive tested this on 2 builds differing only by DYNAMIC_DEBUG
> It works for me on x86-64
>
> However, I just booted a non-dyndbg build on x86-32, and got this.
>

Ok, transient error, went away with a clean build.

tested-by: Jim Cromie <jim.cromie@gmail.com>

thanks
