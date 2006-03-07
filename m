From: Bryan O'Sullivan <bos@pathscale.com>
Subject: Re: [openib-general] Re: [PATCH 6/6] IB: userspace support for
	RDMA connection manager
Date: Mon, 06 Mar 2006 16:05:30 -0800
Message-ID: <1141689930.3814.69.camel@serpentine.pathscale.com>
References: <aday7zn432b.fsf@cisco.com>
	 <20060306.143901.26500391.davem@davemloft.net> <adau0ab42ni.fsf@cisco.com>
	 <20060306.145053.129802994.davem@davemloft.net> <adapskz3zw7.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751078AbWCGAFj@vger.kernel.org>
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adapskz3zw7.fsf@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-03-06 at 15:40 -0800, Roland Dreier wrote:

> Anyway IB works fine with standard INTx interrupts -- MSI is just icing.

Depends on the driver.  Ours needs the interrupt vector rather than the
number, which means we don't work without CONFIG_PCI_MSI.  That is,
unless there's some other way to get the vector that I don't know about
(entirely likely).

	<b
