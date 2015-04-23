From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ethernet: myri10ge: use arch_phys_wc_add()
Date: Thu, 23 Apr 2015 14:28:40 -0400 (EDT)
Message-ID: <20150423.142840.1391606504290988877.davem@davemloft.net>
References: <1429646986-16686-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hykim@myri.com, hkim@cspi.com, netdev@vger.kernel.org,
	luto@amacapital.net, mcgrof@suse.com, sbsiddha@gmail.com,
	mingo@elte.hu, tglx@linutronix.de, jgross@suse.com,
	daniel.vetter@ffwll.ch, airlied@redhat.com, adaplas@gmail.com,
	plagnioj@jcrosoft.com, tomi.valkeinen@ti.com,
	linux-kernel@vger.kernel.org
To: mcgrof@do-not-panic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429646986-16686-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Date: Tue, 21 Apr 2015 13:09:45 -0700

> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> This driver already uses ioremap_wc() on the same range
> so when write-combining is available that will be used
> instead.
> 
 ...
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>

I can't wait forever for the driver maintainers to review this, so
I'm applying it.

Thanks Luis.
