From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: System blocks (hangs) on ifconfig up
Date: Sun, 12 Dec 2010 15:29:48 -0800
Message-ID: <20101212152948.13cb616b@nehalam>
References: <4D04E38A.1040605@trego.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shmulik Hen <shmulik.hen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51698 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808Ab0LLX3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 18:29:51 -0500
In-Reply-To: <4D04E38A.1040605@trego.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Dec 2010 17:00:26 +0200
Shmulik Hen <shmulik.hen@gmail.com> wrote:

> Hello,
> 
> My system is Ubuntu 10.04, running kernel 2.6.32-26-generic.
> 
> Whenever I try to bring up a specific ethernet interface for the second 
> time, my
> system becomes unresponsive for 60 seconds - i.e. no mouse, no keyboard, no
> screen refresh. etc.
> 
> Looking at the driver's code, I could see that it's dev->open() method calls
> wait_event_interruptible_timeout() with a timeout of 60 seconds - exactly
> the delay I'm seeing.
> 
> I have narrowed the code to a bare minimum (see below - loosely based on
> dummy.c), which only calls mdelay(10000) in it's dev->open() method, and
> still, my system blocks for exactly 10 seconds when I run the following
> sequence:
> 
>  > sudo ifconfig shmulik0 up
>  > sudo ifconfig shmulik0 down
>  > sudo ifconfig shmulik0 up
> 
> At this point - the system is stuck for 10 seconds.
> 
> 
> Thanks,
> Shmulik.

What driver is this? Where is the source? It sounds awful

-- 
