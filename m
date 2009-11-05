From: Jon Loeliger <jdl@jdl.com>
Subject: Re: [PATCH RFC] gianfar: Make polling safe with IRQs disabled
Date: Thu, 05 Nov 2009 08:41:06 -0600
Message-ID: <E1N63WM-0003xK-PN@jdl.com>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru>
	<E1N62ti-0003iS-K2@jdl.com>
	<20091105142028.GB17171@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Jason Wessel <jason.wessel@windriver.com>,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-reply-to: <20091105142028.GB17171@oksana.dev.rtsoft.ru> 
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

> 
> Hm, then I'd better remove the #ifdef CONFIG_NETPOLL.
> 
> Interestingly though, why conn_track does the polling with irqs
> disabled, could be a bug in the conn_track? Because pretty much
> drivers assume that polling is called with IRQs enabled.
> 
> If it's easily reproducible, could you replace the printk() with
> WARN_ON(1) and post the backtrace? Or I can try to reproduce the
> issue if you tell me how.
> 
> Thanks!

Yeah, I can reproduce it.  I'll try and get that for you.

jdl
