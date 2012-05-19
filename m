From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Sat, 19 May 2012 10:58:41 +0200
Message-ID: <201205191058.45328.linux@rainbow-software.org>
References: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com> <201205182016.51489.linux@rainbow-software.org> <20120518220305.GC15256@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-1-out2.atlantis.sk ([80.94.52.71]:52263 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755478Ab2ESI7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 04:59:13 -0400
In-Reply-To: <20120518220305.GC15256@windriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 May 2012 00:03:06 Paul Gortmaker wrote:
> [Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.] On 
18/05/2012 (Fri 20:16) Ondrej Zary wrote:
> > On Friday 18 May 2012 19:39:29 Paul Gortmaker wrote:
> > > It was amusing that linux was able to make use of this 1980's
> > > technology on machines long past its intended lifespan, but
> > > it probably should go now -- it is causing issues in some
> > > distros[1], and while that might be fixable, it is just not
> > > worth it.
> > >
> > > [1]
> > > http://www.linuxquestions.org/questions/linux-networking-3/3com-3c501-c
> > >ard- not-detecting-934344/
> >
> > That looks like a bug elsewhere and removing this driver will not fix it.
>
> You miss the point.  We've got someone with a modern i7 machine who is
> getting confused by seeing messages from some ancient 3c501 driver, but
> he doesn't have the context to know it is ancient and the message is a
> red herring.  Will it fix a distro's broken init that tries to modprobe
> everything?  No.  Will it help by not muddying the waters with
> meaningless printk from 3c501 that confuse users?  Yes.

Are you going to remove all drivers that complain that the HW is not present 
because some broken script is trying to modprobe them all? Or only the first 
one? 3c501 is probably the first in alphabet. You remove that and the script 
will modprobe 3c503 then...

-- 
Ondrej Zary
