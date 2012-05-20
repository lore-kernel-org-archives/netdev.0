From: =?ISO-8859-1?Q?Emmanuel_Fust=E9?= <emmanuel.fuste@laposte.net>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Sun, 20 May 2012 18:02:38 +0200
Message-ID: <4FB9159E.3080705@laposte.net>
Reply-To: emmanuel.fuste@laposte.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp06.smtpout.orange.fr ([80.12.242.128]:36785 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab2ETQCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2012 12:02:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 18/05/2012 (Fri 20:16) Ondrej Zary wrote:
> >  On Friday 18 May 2012 19:39:29 Paul Gortmaker wrote:
> >  >  It was amusing that linux was able to make use of this 1980's
> >  >  technology on machines long past its intended lifespan, but
> >  >  it probably should go now -- it is causing issues in some
> >  >  distros[1], and while that might be fixable, it is just not
> >  >  worth it.
> >  >
> >  >  [1]
> >  >  http://www.linuxquestions.org/questions/linux-networking-3/3com-3c501-card-
> >  >not-detecting-934344/
> >
> >  That looks like a bug elsewhere and removing this driver will not fix it.
>
> You miss the point.  We've got someone with a modern i7 machine who is
> getting confused by seeing messages from some ancient 3c501 driver, but
> he doesn't have the context to know it is ancient and the message is a
> red herring.  Will it fix a distro's broken init that tries to modprobe
> everything?  No.  Will it help by not muddying the waters with
> meaningless printk from 3c501 that confuse users?  Yes.
>
> Thanks,
> Paul.
>
> >
> >  --
> >  Ondrej Zary
Oh sh**, even if I could understand the arguments for the MCA part I 
could not
  agree anymore on this.
I you go to this road, kill the m68k architecture and four or five more and
remove half or more of the drivers.
"meaningless printk" ? kill the printk, not the driver. "confuse users" ?
which users ? What you call a users in you comments are people which 
only use
mouse and graphic environments and for which printk are not for ...
Your whole patchset is build around the philosophy perfectly resumed by your
words:
"xxx is being removed, since the 20year old hardware simply isn't capable of
meeting today's software demands on CPU and memory resources."
Such subjective positions are not valid technicals arguments.
Following Linux since twenty years, I could say without making a big mistake
that this is not the Linux way of doing things. Linux would never be 
what it is
today in term of pure code architecture if the easy way of removing 
"disturbing"
and "obsolete in today standards" hardware support code was the way of doing
things.

But perhaps my old way of viewing things is no longer compatible with 
the new
  generations or in what Linux is going to be...

Emmanuel.

PS: My over reaction is PARTLY caused because of special historic symbol
3c501 hardware represent. It was one of the only (if not the only one) 
ethernet
card supported by the Apollo platform and DomainOS. A great and 
important part
of the computer / Unix history.
