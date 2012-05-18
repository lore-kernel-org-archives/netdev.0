From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Fri, 18 May 2012 18:03:06 -0400
Message-ID: <20120518220305.GC15256@windriver.com>
References: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
 <201205182016.51489.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Alan Cox <alan@linux.intel.com>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34374 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966112Ab2ERWDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 18:03:35 -0400
Content-Disposition: inline
In-Reply-To: <201205182016.51489.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.] On 18/05/2012 (Fri 20:16) Ondrej Zary wrote:

> On Friday 18 May 2012 19:39:29 Paul Gortmaker wrote:
> > It was amusing that linux was able to make use of this 1980's
> > technology on machines long past its intended lifespan, but
> > it probably should go now -- it is causing issues in some
> > distros[1], and while that might be fixable, it is just not
> > worth it.
> >
> > [1]
> > http://www.linuxquestions.org/questions/linux-networking-3/3com-3c501-card-
> >not-detecting-934344/
> 
> That looks like a bug elsewhere and removing this driver will not fix it.

You miss the point.  We've got someone with a modern i7 machine who is
getting confused by seeing messages from some ancient 3c501 driver, but
he doesn't have the context to know it is ancient and the message is a
red herring.  Will it fix a distro's broken init that tries to modprobe
everything?  No.  Will it help by not muddying the waters with
meaningless printk from 3c501 that confuse users?  Yes.

Thanks,
Paul.

> 
> -- 
> Ondrej Zary
