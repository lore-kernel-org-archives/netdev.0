From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: mvmdio: fix wait_event_timeout() being called
	with a 1 jiffy timeout.
Date: Tue, 3 Dec 2013 13:34:12 +0000
Message-ID: <20131203133412.GU16735@n2100.arm.linux.org.uk>
References: <20131203122346.GD29282@titan.lakedaemon.net> <1386076560-1886-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
	"David S. Miller" <davem@davemloft.net>,
	Leigh Brown <leigh@solinno.co.uk>,
	Florian Fainelli <florian@openwrt.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386076560-1886-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 03, 2013 at 02:16:00PM +0100, Nicolas Schichan wrote:
> If a timer interrupt kicks right after the wait_event_timeout() call,
> we may endup a reporting timeout before the timeout really occured.

Please see my reply to Jason Cooper about this in the thread
"Spurious timeouts in mvmdio".
