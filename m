From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH 3/3] net-PPP: Delete an unnecessary assignment
Date: Sun, 30 Nov 2014 22:16:02 +0100
Message-ID: <547B8912.7040502@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>	 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>	 <530A086E.8010901@users.sourceforge.net>	 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>	 <530A72AA.3000601@users.sourceforge.net>	 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>	 <530B5FB6.6010207@users.sourceforge.net>	 <alpine.DEB.2.10.1402241710370.2074@hadrien>	 <530C5E18.1020800@users.sourceforge.net>	 <alpine.DEB.2.10.1402251014170.2080@hadrien>	 <530CD2C4.4050903@users.sourceforge.net>	 <alpine.DEB.2.10.1402251840450.7035@hadrien>	 <530CF8FF.8080600@users.sourceforge.net>	 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>	 <530DD06F.4090703@users.sourceforge.net>	 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>	 <531
 7A59D.4@users.sourceforge.net> <547B4886.4080406@users.sourceforge.net>	 <547B4A35.7000500@users.sourceforge.net> <1417377583.4442.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1417377583.4442.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I have no idea why its a patch on its own, and why state->arc4 gets
> special treatment while state->sha1 does not.

I did not fiddle with the data structure element "sha1" because
I assumed that it might be still relevant for the call of a function
like crypto_free_blkcipher().


> This definitely belongs to the previous patch, refactoring error
> handling in mppe_alloc()

I have got different preferences for change distribution over several
patches here.
I find it safer to tackle an assignment clean-up after adjustments
for jump labels.


> Also, it seems your patches do not fix bugs, so so you need to target
> net-next tree, as explained in Documentation/networking/netdev-FAQ.txt

Do you want that I resend my update suggestion?

Regards,
Markus
