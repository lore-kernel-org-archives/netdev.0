From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.18-rc6 1/2] dllink driver: porting v1.19 to linux 2.6.18-rc6
Date: Thu, 7 Sep 2006 12:52:37 +0200
Message-ID: <20060907105237.GA21270@electric-eye.fr.zoreil.com>
References: <1157620189.2904.16.camel@localhost.localdomain> <1157620795.14882.16.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hayim Shaul <hayim@iportent.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, edward_peng@dlink.com.tw,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751530AbWIGK5z@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1157620795.14882.16.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven <arjan@infradead.org> :
[...]
> >  	dev->trans_start = jiffies;
> > +	tasklet_enable(&np->tx_tasklet);
> > +	writew(DEFAULT_INTR, ioaddr + IntEnable);
> > +	return;
> 
> this looks like a PCI posting bug

Btw tx_tasklet is introduced in the relevant struct in patch #2.
Patch #1 will not compile.

-- 
Ueimor
