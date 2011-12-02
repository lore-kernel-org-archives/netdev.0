From: hayeswang <hayeswang@realtek.com>
Subject: RE: [bug?] r8169: hangs under heavy load
Date: Fri, 2 Dec 2011 10:21:08 +0800
Message-ID: <FCF60BC8872E4F1C9C72CE56F0E570C0@realtek.com.tw>
References: <20111125201936.GA26692@elie.hsd1.il.comcast.net> <1322253122.2550.3.camel@edumazet-laptop> <20111125222211.GA13719@electric-eye.fr.zoreil.com> <1322262357.2550.12.camel@edumazet-laptop> <20111126004447.GA14744@electric-eye.fr.zoreil.com> <1322280423.10212.3.camel@edumazet-laptop> <20111127092808.GE21635@elie.hsd1.il.comcast.net> <4ED2A573.1020807@wolke7.net> <20111127231147.GA1784@electric-eye.fr.zoreil.com> <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw> <20111129105440.GA2410@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <booster@wolke7.net>, 'Jonathan Nieder' <jrnieder@gmail.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>,
	'Armin Kazmi' <armin.kazmi@tu-dortmund.de>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111129105440.GA2410@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> > For the 8168c and the later chips, our hardware engineer 
> says that don't enable
> > the RxFIFOOver of IntrMask and don't clear the RxFIFOOver 
> of IntrStatus. The
> > hardware will automatically escape Rx fifo full situation. 
> Although you try to
> > clear the RxFIFOOver of IntrStatus, maybe the bit wouldn't 
> be cleared. Just
> > disregard it.
> 
> Should "later" be understood as gigabit PCI-E only or is 
> there a similar
> difference of behavior between older fast-ethernet PCI-E and 
> more recent
> ones ?
> 

For the fast controller, it should start from rtl8105e. 

Best Regards,
Hayes
