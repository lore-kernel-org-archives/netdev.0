From: Christian Hohnstaedt <christian@hohnstaedt.de>
Subject: Re: qmgr for ixp4xx
Date: Tue, 9 Dec 2008 17:44:20 +0100
Message-ID: <20081209164420.GY16037@mail3.prorata.de>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com> <m3zljby7jm.fsf@maximus.localdomain> <b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com> <m31vwmlidh.fsf@maximus.localdomain> <b0438a630812050859jd9fd55ah5fb3608a964f9567@mail.gmail.com> <m3fxl2jx0v.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miguel ?ngel ?lvarez <gotzoncabanes@gmail.com>,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.prorata.de ([62.145.31.200]:46617 "EHLO mail3.prorata.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713AbYLIQvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 11:51:08 -0500
Content-Disposition: inline
In-Reply-To: <m3fxl2jx0v.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 05, 2008 at 07:29:36PM +0100, Krzysztof Halasa wrote:
> "Miguel ?ngel ?lvarez" <gotzoncabanes@gmail.com> writes:
> 
> > I will check for the 64-queue support patch (thanks Karl). However, if
> > I am not sure they are required. I mean...
> > - HSS0 uses queues 12-22.
> > - HSS1 uses queues 0-10.
> > - That leaves us 10 queues free, doesn't it? Couldn't we use queue 11
> > for eth txreadyq, 23-26 for HSS0 txreadyq, 27-30 for HSS1 txreadyq and
> > 31 for crypto code (which I do not know?)
> 
> Ethernet needs 3 queues per port + 1 (465 CPUs can have 3 Ethernet
> ports), the crypto code probably needs several ones.

Crypto needs 2 queues: 29 and 30.
The numbers are fixed in the microcode, I think.

Christian

