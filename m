From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [ANN] removal of certain net drivers coming soon: eepro100,
 xircom_tulip_cb, iph5526
Date: Thu, 27 Jan 2005 21:22:14 -0800
Message-ID: <20050127212214.58678bef.davem@davemloft.net>
References: <41F952F4.7040804@pobox.com>
	<20050127225725.F3036@flint.arm.linux.org.uk>
	<20050127153114.72be03e2.davem@davemloft.net>
	<20050128001430.C22695@flint.arm.linux.org.uk>
	<20050127164843.08bdb307.davem@davemloft.net>
	<1106877517.18167.311.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rmk+lkml@arm.linux.org.uk, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com, greg@kroah.com,
	akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261460AbVA1F0u@vger.kernel.org>
To: sfeldma@pobox.com
In-Reply-To: <1106877517.18167.311.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 17:58:37 -0800
Scott Feldman <sfeldma@pobox.com> wrote:

> eepro100 does a copy if pkt_len < rx_copybreak, otherwise it send up the
> skb and allocates and links a new one in it's place (see
> speedo_rx_link).

My bad, you're right.  So I wonder too what the difference
is that makes it work on ARM et al.
