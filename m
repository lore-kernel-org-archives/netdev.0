From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Sat, 21 Jun 2008 13:18:42 +0200
Message-ID: <20080621111842.GA32667@orion.carnet.hr>
References: <20080616140454.GD5350@solarflare.com> <1551EAE59135BE47B544934E30FC4FC002AABD77@nt-irva-0751.brcm.ad.broadcom.com> <20080616191354.GA11760@orion.carnet.hr> <20080616213821.GA8844@orion.carnet.hr> <20080616214829.GA9334@orion.carnet.hr> <1213659908.18055.26.camel@dell> <20080617223708.GA30292@orion.carnet.hr> <1213742842.5199.8.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>, mirrors@debian.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:47256 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbYFULSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jun 2008 07:18:46 -0400
Content-Disposition: inline
In-Reply-To: <1213742842.5199.8.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 03:47:22PM -0700, Michael Chan wrote:
> On Wed, 2008-06-18 at 00:37 +0200, Josip Rodin wrote:
> > After applying this patch, two rsync runs went through without any problem,
> > yay.
> > 
> > Yet, there were no alerts from the new printk in the patch...?
> 
> Please keep monitoring the printks during future rsyncs with those HTB
> rules.  May be we're just lucky and not hitting the problem this time.

Still nothing after four days. I'm starting to wonder...

The only thing that I did that was slightly out of the ordinary was that
I applied your patch, ran make modules and then modules_install, and then
modprobe -r bnx2, modprobe bnx2; IOW I didn't reboot the whole kernel or
reinitialize HTB. Should I try to do any of that?

-- 
     2. That which causes joy or happiness.
