From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH v2 net-next 1/2] r8169: enable ALDPS for power saving
Date: Wed, 24 Oct 2012 13:55:28 +0800
Message-ID: <F44332CBDDB64F93B0BB3785EC1AD46E@realtek.com.tw>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com> <1350974831-1438-1-git-send-email-hayeswang@realtek.com> <20121023193304.GB10463@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121023193304.GB10463@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> > +static void r810x_aldps_disable(struct rtl8169_private *tp)
> > +{
> > +	rtl_writephy(tp, 0x1f, 0x0000);
> > +	rtl_writephy(tp, 0x18, 0x0310);
> > +	msleep(100);
> > +}
> 
> rtl8402_hw_phy_config used a msleep(20). Meguesses it won't 
> hurt, right ?

No, it won't hurt. The delay make suer there is enough time to pause ALDPS.
 
Best Regards,
Hayes
