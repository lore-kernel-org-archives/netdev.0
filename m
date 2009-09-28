From: Manuel Prinz <manuel@debian.org>
Subject: [Fwd: Re: Bug#538372: header failure including netlink.h (or
	uio.h)]
Date: Mon, 28 Sep 2009 13:24:44 +0200
Message-ID: <1254137084.4756.11.camel@ce170155.zmb.uni-duisburg-essen.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ts-cs.de ([78.46.91.78]:38091 "EHLO lsrv5.ts-cs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463AbZI1LbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2009 07:31:23 -0400
Received: from localhost (lsrv5.ts-cs.de [127.0.0.1])
	by lsrv5.ts-cs.de (Postfix) with ESMTP id 4DD5030801C
	for <netdev@vger.kernel.org>; Mon, 28 Sep 2009 13:24:45 +0200 (CEST)
Received: from lsrv5.ts-cs.de ([127.0.0.1])
 by localhost (lsrv5.ts-cs.de [127.0.0.1]) (amavisd-maia, port 10024)
 with ESMTP id 15545-09 for <netdev@vger.kernel.org>;
 Mon, 28 Sep 2009 13:24:45 +0200 (CEST)
Received: from [132.252.170.155] (unknown [132.252.170.155])
	by lsrv5.ts-cs.de (Postfix) with ESMTPSA id 2C418308011
	for <netdev@vger.kernel.org>; Mon, 28 Sep 2009 11:24:45 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I'm forwarding this bug in Debian (http://bugs.debian.org/538372) as
requested by the Debian kernel team. A patch is available. Applying just
the first hunk fixes the issue for me. I've not enough kernel knowledge
to judge if this fix is a proper solution, though.

It would be really great if someone could have a look at it. Thanks in
advance! (And please CC me in replies. Thanks!)

Best regards,

Manuel


-------- Weitergeleitete Nachricht --------
> Von: Moritz Muehlenhoff <jmm@inutil.org>
> An: Manuel Prinz <manuel@debian.org>
> Kopie: Moritz Muehlenhoff <jmm@inutil.org>, 538372@bugs.debian.org
> Betreff: Re: Bug#538372: header failure including netlink.h (or uio.h)
> Datum: Sun, 27 Sep 2009 13:30:10 +0200
> 
> On Fri, Sep 18, 2009 at 10:59:19PM +0200, Manuel Prinz wrote:
> > Am Dienstag, den 01.09.2009, 18:53 +0200 schrieb Moritz Muehlenhoff:
> > > On Sat, Jul 25, 2009 at 01:55:04PM +0200, Bastian Blank wrote:
> > > > Patches attached:
> > > > * Fix uio.h
> > > > * Remove socket.h backward compatibility code.
> > > 
> > > uio.h has been marked __KERNEL__-only upstream in commit
> > > 812ed032cdc8138b7546eecc996879756b92d801.
> > > 
> > > Did you submit your socket.h patch upstream?
> > 
> > I am bitten by that bug as well. The change in uio.h did not fix it. I
> > updated the patch for socket.h (attached) but I'm not sure if all
> > changes are needed, though. Applying only the first hunk (#ifdef line)
> > fixed all build issue for me.
> 
> Can you please forward this upstream? I suppose netdev@vger.kernel.org would
> be the best list to contact.
> 
> Cheers,
>         Moritz

