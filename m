From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: 3.16-rc6+: r8169 fresh new irq lock inversion
Date: Thu, 24 Jul 2014 09:01:27 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2510016@RTITMBSV03.realtek.com.tw>
References: <20140722081840.GA6462@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Borislav Petkov <bp@alien8.de>, nic_swsd <nic_swsd@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140722081840.GA6462@pd.tnic>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Borislav Petkov [mailto:bp@alien8.de] 
> Sent: Tuesday, July 22, 2014 4:19 PM
> To: nic_swsd
> Cc: netdev@vger.kernel.org; lkml
> Subject: 3.16-rc6+: r8169 fresh new irq lock inversion
> 
> Hi all,
> 
> I got this new lockdep splat after booting rc6 + tip/master this
> morning. I haven't seen it before so it must be new in rc6 
> which should
> be easy to pinpoint... or maybe there's already a fix queued 
> somewhere. :)

I have no idea about why you see the messages.  I don't think
the patches which submitted previously for r8169.c  would cause
the problem. Although I have submitted some patches about IPv6,
the hw checksum should be off by default. That is, the behavior
should be the same with the previous one.
 
Best Regards,
Hayes
