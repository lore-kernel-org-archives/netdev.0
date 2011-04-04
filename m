From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: Re: [PATCH] X86:NET:Replaced a deprecated function .
Date: Mon, 4 Apr 2011 11:53:22 +0200
Message-ID: <20110404095322.GA10089@isilmar-3.linta.de>
References: <20110404093620.GA4896@isilmar-3.linta.de> <201104041743511096883@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem <davem@davemloft.net>, padovan <padovan@profusion.mobi>,
	joe <joe@perches.com>, marcel <marcel@holtmann.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: "wanlong.gao" <wanlong.gao@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201104041743511096883@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2011 at 05:44:00PM +0800, wanlong.gao wrote:
> You means that some drivers still not capable of IRQF_SHARED?

That's the issue. I do not know whether this driver is capable of
IRQF_SHARED as it should be. If it is, you may replace the
pcmcia_request_exclusive_irq() with pcmcia_request_irq(), and the warning
will be gone.

Best,
	Dominik
