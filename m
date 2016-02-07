From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] net: ethernet: davicom: fix devicetree irq resource
Date: Sun, 7 Feb 2016 13:34:26 +0100
Message-ID: <20160207123426.GA6022@electric-eye.fr.zoreil.com>
References: <1454796693-4446-1-git-send-email-robert.jarzmik@free.fr>
 <20160207102303.GA4976@electric-eye.fr.zoreil.com>
 <87twlk3ija.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87twlk3ija.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Jarzmik <robert.jarzmik@free.fr> :
> Francois Romieu <romieu@fr.zoreil.com> writes:
[...]
> > If you have some spare time, it would be nice to avoid db->irq_wake leak
> > on probe failure or driver removal.
> Sorry but not in this patch.

Of course. Different topic => different patch.

> I suppose the right patch would be to use devm_*() in the probe function for
> ioremaps and request_irqs, which would address this point.

I'd rather avoid devm_* on netdev.

-- 
Ueimor
