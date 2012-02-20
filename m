From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] r8169: Rx FIFO overflow fixes.
Date: Tue, 21 Feb 2012 00:22:19 +0100
Message-ID: <20120220232219.GB13960@electric-eye.fr.zoreil.com>
References: <4ED2A573.1020807@wolke7.net> <20111127231147.GA1784@electric-eye.fr.zoreil.com> <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw> <20111129105440.GA2410@electric-eye.fr.zoreil.com> <4ED538EC.4010509@wolke7.net> <20111201102000.GA14013@electric-eye.fr.zoreil.com> <4ED7E6AB.6050308@wolke7.net> <20111201222612.GA27998@electric-eye.fr.zoreil.com> <20111205063045.GA3103@electric-eye.fr.zoreil.com> <20120220023740.GA4433@burratino>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: booster@wolke7.net, hayeswang <hayeswang@realtek.com>,
	"'Eric Dumazet'" <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"'nic_swsd'" <nic_swsd@realtek.com>, linux-kernel@vger.kernel.org,
	"'Armin Kazmi'" <armin.kazmi@tu-dortmund.de>,
	Lucas Stach <dev@lynxeye.de>
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120220023740.GA4433@burratino>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jonathan Nieder <jrnieder@gmail.com> :
[...]
> What do you think?  Is there any way I can help?  (E.g., given rough
> guidelines about what approach is acceptable I'd be happy to work with
> Gerd to produce a tested patch that does (1) and (2) but not (3) for
> 3.0.y.)

Few guidelines are needed: go for it.

I would trust the manufacturer for (3) though.

If you still have time to help, you should really try to break davem-next
branch. I won't claim it's bug-free but the IRQ / napi / Tx processing in
the r8169 driver should now be easier to read and maintain.

-- 
Ueimor
