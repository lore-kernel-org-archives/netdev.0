From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC PATCH net-next] qfq: handle the case that front slot is
 empty
Date: Tue, 23 Oct 2012 16:53:52 +0800
Message-ID: <1350982432.26308.8.camel@cr0>
References: <1350965711-4390-1-git-send-email-amwang@redhat.com>
	 <F36C0EC1-0A4C-48FB-ABF3-A89575A9287E@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Paolo Valente <paolo.valente@unimore.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932503Ab2JWIyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 04:54:07 -0400
In-Reply-To: <F36C0EC1-0A4C-48FB-ABF3-A89575A9287E@unimore.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-23 at 09:09 +0200, Paolo Valente wrote:
> The crash you reported is one of the problems I tried to solve with my last fixes.
> After those fixes I could not reproduce this crash (and other crashes) any more, but of course I am still missing something.

I am using the latest net-next, so if your patches are in net-next,
then the problem of course still exists.

> 
> Il giorno 23/ott/2012, alle ore 06:15, Cong Wang ha scritto:
> 
> > I am not sure if this patch fixes the real problem or just workarounds
> > it. At least, after this patch I don't see the crash I reported any more.
> 
> It is actually a workaround: if the condition that triggers your workaround holds true, then the group data structure is already inconstent, and qfq is likely not to schedule classes correctly.
> I will try to reproduce the crash with the steps you suggest, and try to understand what is still wrong as soon as I can.
> 

OK, I don't pretend I understand qfq. And I can help you to test
patches.

Thanks!
