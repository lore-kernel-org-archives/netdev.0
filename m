From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Wed, 28 Nov 2012 22:24:38 +0100
Message-ID: <20121128212438.GA941@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127182843.GA11597@shrek.podlesie.net>
 <20121128201837.GA912@shrek.podlesie.net>
 <1354135481.21562.98.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354135481.21562.98.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2012 at 08:44:41PM +0000, David Woodhouse wrote:
> On Wed, 2012-11-28 at 21:18 +0100, Krzysztof Mazur wrote:
> > 
> > +void vcc_pop_any(struct atm_vcc *vcc, struct sk_buff *skb)
> > +{
> > +       if (vcc->pop)
> > +               vcc->pop(vcc, skb);
> 
> if (vcc && vcc->pop) perhaps? 
> 

yes, we can do that, at least "he" and "nicstar" use that in some cases.

Krzysiek
