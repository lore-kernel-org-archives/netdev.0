From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] change netdevice to use struct device instead of struct
 class_device
Date: Mon, 03 Jul 2006 18:57:47 -0700 (PDT)
Message-ID: <20060703.185747.74753207.davem@davemloft.net>
References: <20060703224719.GA14176@kroah.com>
	<44A9A345.8040706@garzik.org>
	<20060703231610.GA18352@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751375AbWGDB5c@vger.kernel.org>
To: greg@kroah.com
In-Reply-To: <20060703231610.GA18352@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Mon, 3 Jul 2006 16:16:10 -0700

> No, not really.  According to Documentation/ABI/testing/sysfs-class all
> code that uses /sys/class/foo/ needs to be able to handle the fact that
> those entries might be symlinks and not just directories.  Everything
> that I know of already works properly because the input layer has had
> symlinks in /sys/class/input for quite some time now.
> 
> Do you know of any tools that use /sys/class/net/ that can not handle
> symlinks there?  I've been running this on my boxes for about a week now
> with no noticeable issues.  Renaming interfaces works just fine too.

I do not think this change will cause any problems.
