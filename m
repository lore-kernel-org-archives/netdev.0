From: hayeswang <hayeswang@realtek.com>
Subject: RE: [bug?] r8169: hangs under heavy load
Date: Tue, 29 Nov 2011 14:47:24 +0800
Message-ID: <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw>
References: <20111124044137.GA18262@elie.hsd1.il.comcast.net> <4ECFE7A7.5070300@wolke7.net> <20111125201936.GA26692@elie.hsd1.il.comcast.net> <1322253122.2550.3.camel@edumazet-laptop> <20111125222211.GA13719@electric-eye.fr.zoreil.com> <1322262357.2550.12.camel@edumazet-laptop> <20111126004447.GA14744@electric-eye.fr.zoreil.com> <1322280423.10212.3.camel@edumazet-laptop> <20111127092808.GE21635@elie.hsd1.il.comcast.net> <4ED2A573.1020807@wolke7.net> <20111127231147.GA1784@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Jonathan Nieder' <jrnieder@gmail.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>,
	'Armin Kazmi' <armin.kazmi@tu-dortmund.de>
To: 'Francois Romieu' <romieu@fr.zoreil.com>, <booster@wolke7.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111127231147.GA1784@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> 
> Hayes, does the 8168c require something special to recover 
> from Rx FIFO
> overflow ?
> 

For the 8168c and the later chips, our hardware engineer says that don't enable
the RxFIFOOver of IntrMask and don't clear the RxFIFOOver of IntrStatus. The
hardware will automatically escape Rx fifo full situation. Although you try to
clear the RxFIFOOver of IntrStatus, maybe the bit wouldn't be cleared. Just
disregard it.
 
Best Regards,
Hayes
