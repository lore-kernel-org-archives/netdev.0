From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] forcedeth: fix random memory scribbling bug
Date: Sat, 24 Dec 2005 22:20:57 +0100
Message-ID: <20051224212057.GA22117@electric-eye.fr.zoreil.com>
References: <43AD4ADC.8050004@colorfullife.com> <Pine.LNX.4.64.0512241145520.14098@g5.osdl.org> <43ADA7D0.9010908@colorfullife.com> <Pine.LNX.4.64.0512241241230.14098@g5.osdl.org> <43ADB83A.4090005@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>,
	Manfred Spraul <manfred@colorfullife.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750732AbVLXVYs@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <43ADB83A.4090005@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> Paranoia -- the situation above never occurs.  It is coded as are other 
> drivers:  np->rx_buf_sz only changes in ->change_mtu(), which (a) is 
> serialized against close and (b) always stops the engine and drains RX 
> skbs before changing the size.

Yep.

Btw, regarding the "more sense" thing, now:
- pci_{map/unmap}_single() uses skb->foo
- nv_alloc_rx() and friends use np->rx_buf_sz

(thread moved to netdev@vger.kernel.org)

--
Ueimor
