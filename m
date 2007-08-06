From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon,  6 Aug 2007 21:36:15 +0200
Message-ID: <JMDAGF$E41775B89CFE6CA59D87D92B60DD7A0B@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "cebbert" <cebbert@redhat.com>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	"jarkao2" <jarkao2@o2.pl>, "tglx" <tglx@linutronix.de>,
	"torvalds" <torvalds@linux-foundation.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"shemminger" <shemminger@linux-foundation.org>,
	"linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>,
	"akpm" <akpm@linux-foundation.org>,
	"alan" <alan@lxorguk.ukuu.org.uk>
To: "mingo" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.xandmail.com ([212.155.184.97]:55011 "EHLO
	mail.xandmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763606AbXHFUDr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 16:03:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> * Chuck Ebbert <cebbert@redhat.com> wrote:
> 
> > Before, they would print:
> > 
> > eth0: transmit timed out, tx_status 00 status e601.
> >   diagnostics: net 0ccc media 8880 dma 0000003a fifo 0000
> > eth0: Interrupt posted but not delivered -- IRQ blocked by another device?
> >   Flags; bus-master 1, dirty 295757(13) current 295757(13)
> >   Transmit list 00000000 vs. f7150a20.
> >   0: @f7150200  length 80000070 status 0c010070
> >   1: @f71502a0  length 80000070 status 0c010070
> >   2: @f7150340  length 8000005c status 0c01005c
> > 
> > Now they just work, apparently...
> 
> could you please try the patch below? If this doesnt do the trick then i 
> guess we need to revert that change.

I confirm that the latest fedora kernel 2.6.22.1-41.fc7 (with the removal of [PATCH] genirq: do not mask interrupts by default) still work on my machine for 3 days.

Atm I'm still stressing the network (2 * 3com cards + 1 onboard nvidia card) to be sure.

Jb



