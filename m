From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH 1/1] r8169.c correct MSIEnable register offset
Date: Thu, 15 Dec 2011 16:34:34 +0800
Message-ID: <6678D92472CB4636B48A3D97ADE27BB9@realtek.com.tw>
References: <CABJLtPHWfRLcbzDFR0ZXe4da3jv04eDZL2CabF1FTcaadoy0xQ@mail.gmail.com><20111214213713.GA2907@electric-eye.fr.zoreil.com> <20111215.014359.1153990753442293322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <cantona@cantona.no-ip.org>, <linux-kernel@vger.kernel.org>,
	'nic_swsd' <nic_swsd@realtek.com>, <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>, <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111215.014359.1153990753442293322.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Thursday, December 15, 2011 2:44 PM
> To: romieu@fr.zoreil.com
> Cc: cantona@cantona.no-ip.org; Hayeswang; 
> linux-kernel@vger.kernel.org; nic_swsd; netdev@vger.kernel.org
> Subject: Re: [PATCH 1/1] r8169.c correct MSIEnable register offset
> 
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Wed, 14 Dec 2011 22:37:13 +0100
> 
> > Su Kang Yin <cantona@cantona.no-ip.org> :
> >> correct MSIEnable (bit 5) register to Config1 (offset 
> 0x52) instead of
> >> Config2 (offset 0x53)
> > 

The bit 5 of config1 (0x52) is reserved. And the bit 5 of Config2 (0x53) is
MSIEnable only for 8169 controler series.

> > I wonder where the inspiration for the MSIEnable bit came from.
> > It looks like something was confused with the Message Control word
> > in PCI space.
> > 
> > Imho you can simply remove it altogether.
> 
> Someone should find out what the real situation is with this.
> 
> Maybe it mirrors the PCI config space setting and is read-only, maybe
> not.  But it should be determined for sure before changing this. :-)
> 
