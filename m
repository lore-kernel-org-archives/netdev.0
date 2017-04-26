From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH v1] net: phy: fix auto-negotiation stall due to
 unavailable interrupt
Date: Wed, 26 Apr 2017 12:21:21 +0200
Message-ID: <20170426102121.traoy23tglmacjfl@piout.net>
References: <1492686004-30527-1-git-send-email-al.kochet@gmail.com>
 <1492686004-30527-2-git-send-email-al.kochet@gmail.com>
 <20170425.103644.75674234677063517.davem@davemloft.net>
 <B99ADC0E-A793-4334-A086-9F2CE045AB7E@gmail.com>
 <20170425200911.d7zfakqs5k5zwisg@piout.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Roger Quadros <rogerq@ti.com>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: Alexander Kochetkov <al.kochet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:45124 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1037687AbdDZKVX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 06:21:23 -0400
Content-Disposition: inline
In-Reply-To: <20170425200911.d7zfakqs5k5zwisg@piout.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/04/2017 at 22:09:11 +0200, Alexandre Belloni wrote:
> Hi,
> 
> On 25/04/2017 at 18:25:30 +0300, Alexander Kochetkov wrote:
> > Hello David!
> > 
> > > 25 апр. 2017 г., в 17:36, David Miller <davem@davemloft.net> написал(а):
> > > 
> > > So... what are we doing here?
> > > 
> > > My understanding is that this should fix the same problem that commit
> > > 99f81afc139c6edd14d77a91ee91685a414a1c66 ("phy: micrel: Disable auto
> > > negotiation on startup") fixed and that this micrel commit should thus
> > > be reverted to improve MAC startup times which regressed.
> > > 
> > > Florian, any guidance?
> > 
> > Yes, this should be done.
> > 
> > I aksed Alexandre to check if 99f81afc139c6edd14d77a91ee91685a414a1c66 ("phy: micrel: Disable auto
> > negotiation on startup») can be reverted, and he answered what it may do that
> > sometime this/next week.
> > 
> 
> Yes, it can be safely reverted after Alexander's patch. I had to test on
> v4.7 because we are not using interrupts on those boards since v4.8
> (another issue to be fixed).
> 
> As Florian pointed out, at the time I sent my patch, I didn't have time
> to investigate whether this was affecting other phys, see
> https://lkml.org/lkml/2016/2/26/766
> 
> I can send the revert or you can do it.
> 

I've now tested on linux-next after fixing phy interrupts in the macb
driver and this also fixes the issue I was trying to solve with:
https://lkml.org/lkml/2016/4/15/786

-- 
Alexandre Belloni, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
