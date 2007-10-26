From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24-rc1 fails with lockup - /sbin/ifconfig / inet_ioctl() /
	dev_close() / rtl8169_down()
Date: Fri, 26 Oct 2007 19:56:13 +0200
Message-ID: <20071026175613.GA18770@elte.hu>
References: <alpine.LFD.0.999.0710232057080.30120@woody.linux-foundation.org> <1193232344.32208.0.camel@localhost> <20071024142759.GA13657@elte.hu> <1193241191.14314.8.camel@localhost> <20071024155521.GA16690@elte.hu> <1193242267.6914.6.camel@twins> <1193378269.17910.4.camel@localhost> <20071026063733.GA12426@elte.hu> <20071026094833.539a69aa@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Romano Giannetti <romanol@upcomillas.es>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:36756 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516AbXJZR4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 13:56:34 -0400
Content-Disposition: inline
In-Reply-To: <20071026094833.539a69aa@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> > hm, from your log it appears that lockdep did not find anything, 
> > still the hang does trigger.
> > 
> > it's /sbin/ifconfig and inet_ioctl() / dev_close() / rtl8169_down() 
> > that seems to be hanging. I've extracted the relevant backtrace 
> > below. I've Cc:-ed people who might have a better idea about what's 
> > going on.
> 
> Are you building with NAPI enabled or not. Looks like the following 
> might help the non-napi case.

the config from:

  http://www.dea.icai.upcomillas.es/romano/linux/info/2624rc1_1/

suggests that NAPI was disabled:

  CONFIG_R8169=m
  # CONFIG_R8169_NAPI is not set
  CONFIG_R8169_VLAN=y

	Ingo
