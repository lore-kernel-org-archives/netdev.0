From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Thu, 5 Jan 2006 22:04:44 +0100
Message-ID: <20060105210444.GA5878@xi.wantstofly.org>
References: <20060105181826.GD12313@stusta.de> <43BD6C03.2080605@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, saw@saw.sw.com.sg,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932191AbWAEVE7@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <43BD6C03.2080605@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 05, 2006 at 01:57:07PM -0500, Jeff Garzik wrote:

> >This patch removes the obsolete drivers/net/eepro100.c driver.
> >
> >Is there any known problem in e100 still preventing us from removing 
> >this driver (it seems noone was able anymore to verify the ARM problem)?
> 
> Still waiting to see if e100 in -mm works on ARM.

e100 seems to work okay on the (modern) ARM CPUs I've tried.  The case
where e100 failed but eepro100 worked was (I think) on older ARM hardware,
and I'm not sure whether that kind of hardware is used anymore..


cheers,
Lennert
