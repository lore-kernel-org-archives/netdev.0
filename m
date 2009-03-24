From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Revert "gro: Fix legacy path napi_complete crash", (was: Re:
	Linux 2.6.29)
Date: Tue, 24 Mar 2009 14:12:08 +0100
Message-ID: <20090324131208.GA10157@elte.hu>
References: <alpine.LFD.2.00.0903231617550.3032@localhost.localdomain> <20090324130202.GA32469@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thoma
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:36367 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758095AbZCXNMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 09:12:52 -0400
Content-Disposition: inline
In-Reply-To: <20090324130202.GA32469@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(netdev Cc:-ed)

* Ingo Molnar <mingo@elte.hu> wrote:

> Yesterday about half of my testboxes (3 out of 7) started getting 
> weird networking failures: their network interface just got stuck 
> completely - no rx and no tx at all. Restarting the interface did 
> not help.

> I've attached the reproducer (non-SMP) .config. The system has:

Note, the .config is randconfig derived. There was a stage of the 
tests when about every ~5-10th randconfig was failing, so i dont 
think it's a rare config combo that triggers this. (but there were 
other stages where 30 randconfig in a row went fine so it's hard to 
tell.)

In the worst case the hang needed 2 million packets to trigger - 
that's why i set the limit in the tests to 6 million packets.

	Ingo
