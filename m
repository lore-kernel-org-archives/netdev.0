From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: patch tulip-natsemi-dp83840a-phy-fix.patch added to -mm tree
Date: Thu, 26 May 2005 22:16:50 -0400
Message-ID: <42968312.90901@pobox.com>
References: <200505101955.j4AJtX9x032464@shell0.pdx.osdl.net> <42881C58.40001@pobox.com> <20050516050843.GA20107@colo.lackof.org> <4288CE51.1050703@pobox.com> <20050521223959.GA4337@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>, akpm@osdl.org,
	T-Bone@parisc-linux.org, varenet@parisc-linux.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261439AbVE0CRA@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050521223959.GA4337@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [tulip_media_select]
> 
>>1) called from timer context, from the media poll timer
>>
>>2) called from spin_lock_irqsave() context, in the ->tx_timeout hook.
>>
>>The first case can be fixed by moved all the timer code to a workqueue. 
>> Then when the existing timer fires, kick the workqueue.
>>
>>The second case can be fixed by kicking the workqueue upon tx_timeout 
>>(which is the reason why I did not suggest queue_delayed_work() use).
> 
> 
> First try below. It only moves tulip_select_media() to process context.
> The original patch (with s/udelay/msleep/ or such) is not included.
> 
> Patch applies/compiles against 2.6.12-rc4.

Looks pretty good to me, at first look.

I'll give it some thought, and probably apply it, in a few days.

	Jeff
