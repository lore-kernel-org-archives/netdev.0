From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] add netconsole support for xen-netfront
Date: Tue, 24 Jan 2012 08:58:00 +0000
Message-ID: <1327395480.17019.1.camel@dagon.hellion.org.uk>
References: <1326271956-25565-1-git-send-email-zhenzhong.duan@oracle.com>
	 <20120112141745.GA7685@phenom.dumpdata.com>
	 <1326452769.17210.331.camel@zakaz.uk.xensource.com>
	 <4F15EB3E.3060700@oracle.com> <20120117215100.GA25367@phenom.dumpdata.com>
	 <4F160113.1030503@oracle.com>
	 <1326877176.29475.37.camel@dagon.hellion.org.uk>
	 <4F173467.90106@oracle.com> <20120123182443.GA22963@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tina Yang <tina.yang@oracle.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Zhenzhong Duan <zhenzhong.duan@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"gurudas.pai@oracle.com" <gurudas.pai@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120123182443.GA22963@phenom.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-01-23 at 18:24 +0000, Konrad Rzeszutek Wilk wrote:

> Ok, so let me update the git commit description to include this.
> 
> I am listed as the maintainer but I would have thought that it should
> go through David?

Generally folks listed as specific network driver maintainers are
sub-maintainers under David, so the flow would be You->David->Linus. For
netback I generally don't bother with the "You->" bit but just Ack them
on list and David picks them up.

> David, should it go through you or should I stick it in my tree? Here
> is the patch with a better git description.
> 
> From 1c265b7946f222ab6a5aac5245a0ab84618772c8 Mon Sep 17 00:00:00 2001
> From: Zhenzhong Duan <zhenzhong.duan@oracle.com>
> Date: Thu, 12 Jan 2012 10:18:29 +0800
> Subject: [PATCH] xen/netfront: add netconsole support.
> 
> add polling interface to xen-netfront device to support netconsole
> 
> This patch also alters the spin_lock usage to use irqsave variant.
> Documentation/networking/netdevices.txt states that start_xmit
> can be called with interrupts disabled by netconsole and therefore using
> the irqsave/restore locking in this function is looks correct.
> 
> Signed-off-by: Tina.Yang <tina.yang@oracle.com>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Signed-off-by: Zhenzhong.Duan <zhenzhong.duan@oracle.com>
> Tested-by: gurudas.pai <gurudas.pai@oracle.com>
> [v1: Copy-n-pasted Ian Campbell comments]
> Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>
