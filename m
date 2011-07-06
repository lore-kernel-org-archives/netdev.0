From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 2/6] r8169: modify the flow hw reset
Date: Wed, 6 Jul 2011 15:48:51 +0800
Message-ID: <EF32BED7323642F29CF5AA3EA7048C78@realtek.com.tw>
References: <1309859095-32031-1-git-send-email-hayeswang@realtek.com> <1309859095-32031-2-git-send-email-hayeswang@realtek.com> <20110705185515.GB5105@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110705185515.GB5105@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Wednesday, July 06, 2011 2:55 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next 2/6] r8169: modify the flow hw reset
> 
> >  
> > +static void rtl_rx_close(struct rtl8169_private *tp) {
> > +	void __iomem *ioaddr = tp->mmio_addr;
> > +	u32 rxcfg = RTL_R32(RxConfig);
> > +
> > +	rxcfg &= ~(AcceptBroadcast | AcceptMulticast |
> > +		   AcceptMyPhys | AcceptAllPhys);
> > +	RTL_W32(RxConfig, rxcfg);
> > +}
> > +
> 
> Should not error and runt packets be considered too ?
> 
> <shot in the dark>
> Is there any relationship with commit 
> ca52efd5490f97f396d3c5863ba714624f272033 ?
> </shot in the dark>
> 

No, there is no relationship about that.
