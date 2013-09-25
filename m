From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Kernel Panic Sending Frames Using dev_queue_xmit()
Date: Wed, 25 Sep 2013 19:19:34 +0100
Message-ID: <1380133174.2222.13.camel@bwh-desktop.uk.level5networks.com>
References: <CAFu7c2V+gubfzG4HdWtPWJ-w2x3J-RToUT2mdahcKSgn66fDzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Merlin Davis <me.the.wizard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57273 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459Ab3IYSTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 14:19:37 -0400
In-Reply-To: <CAFu7c2V+gubfzG4HdWtPWJ-w2x3J-RToUT2mdahcKSgn66fDzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-25 at 00:32 -0700, Merlin Davis wrote:
> I am getting kernel panics in the 3.5.0 kernel (and 2.6.39) when
> sending Ethernet frames using allocated SKBs passed to
> dev_queue_xmit() from a kernel module.  I have trimmed the problem to
> a very small module that continually sends the same (captured and
> verified) frame from one net_device.  The frames are sent without a
> socket in I believe the same way that net/ipv4/arp.c creates and sends
> them.  The panic can occur after a few seconds or a few minutes, but
> always occurs.  It is USUALLY a "kernel NULL pointer dereference" and
> USUALLY occurs within __kfree_skb(), but both the error and the
> location can vary.  I have not been successful in capturing a complete
> oops message.
> 
> There is a GitHub repository with the module, a makefile, and more
> notes about how I have tested and what I have tried at
> https://github.com/me-the-wizard/ksend
>
> I do not know if there is something I am doing wrong with the SKBs or
> if I have stumbled upon a bug in the kernel.  After weeks of attempts
> I believe I have reached the limit of my ability to figure this out.
> Can anyone offer some guidance?

You are more likely to get help if you include the code in your email
rather than linking to it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
