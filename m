From: Sylvain Le Gall <sylvain@le-gall.net>
Subject: Re: Pull request for 'r8169-for-jeff-20070919' branch
Date: Fri, 21 Sep 2007 00:16:59 +0200
Message-ID: <20070920221659.GC32491@yocto.gallu.homelinux.org>
References: <20070919195606.GA3871@electric-eye.fr.zoreil.com> <46F2D24A.6050200@redhat.com> <20070920204437.GB13512@electric-eye.fr.zoreil.com> <46F2E590.1070704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, David Gundersen <gundy@iinet.net.au>,
	Edward Hsu <edward_hsu@realtek.com.tw>, Roel.Teuwen@advalvas.be
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.orange.fr ([80.12.242.94]:45403 "EHLO smtp27.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316AbXITWRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 18:17:05 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2701.orange.fr (SMTP Server) with ESMTP id 4D3441C00098
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 00:17:01 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <46F2E590.1070704@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Sep 20, 2007 at 05:26:40PM -0400, Chuck Ebbert wrote:
> On 09/20/2007 04:44 PM, Francois Romieu wrote:
> > Chuck Ebbert <cebbert@redhat.com> :
> > [...]
> >> People are still reporting hangs with this card in 2.6.22.6, are there
> >> any fixes appropriate for that?
> > 
> > $ grep 2.6.22.6 ~/Mail/linux/bugs/pending
> > $ grep 2.6.22.6 ~/Mail/romieu
> > [nothing besides Sylvain's success with 2.6.22.6 + the r8169 test driver]
> > $ less +/2.6.22.6 ~/Mail/linux/netdev/200709 
> > [nada]
> > $ less +/816[89] ~/Mail/linux/kernel/200737
> > [...]
> > 
> > /me scratches head...
> > 
> 
> Looking again, it may not be r8169's fault, but it is involved. It
> used to hang and could be restarted by pulling the cable and reinserting
> it, but now it just locks solid:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=252955
> 
> Will ask the reporter to test with a different adapter.
> 

I permit myself to reply, since i was CCed.

I have this kind of error at the beginning. It was quite strange, but
caused by IRQ problems: 
* eth0, cdrom (ide1 or something like that), audio controler, usb on the
  same IRQ
* from time to time i get very strange behavior:
** lost CDROM
** cannot move mouse
** strange latency on the network (ping to google go from 65ms to 500ms)
* when i :
** use USB
** use audio

In fact, that was a hidden IRQ conflict... I solve it by upgrading BIOS.

Kind regards
Sylvain Le Gall

ps: maybe it has nothing to do with your problem, if so please forgive
me for the noise

