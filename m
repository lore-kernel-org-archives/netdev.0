From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [openib-general] Re: [PATCH 6/6] IB: userspace support for RDMA connection manager
Date: Mon, 06 Mar 2006 16:10:56 -0800
Message-ID: <adad5gz3yi7.fsf@cisco.com>
References: <aday7zn432b.fsf@cisco.com>
	<20060306.143901.26500391.davem@davemloft.net>
	<adau0ab42ni.fsf@cisco.com>
	<20060306.145053.129802994.davem@davemloft.net>
	<adapskz3zw7.fsf@cisco.com>
	<1141689930.3814.69.camel@serpentine.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751283AbWCGALA@vger.kernel.org>
To: "Bryan O'Sullivan" <bos@pathscale.com>
In-Reply-To: <1141689930.3814.69.camel@serpentine.pathscale.com> (Bryan O'Sullivan's message of "Mon, 06 Mar 2006 16:05:30 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Bryan> Depends on the driver.  Ours needs the interrupt vector
    Bryan> rather than the number, which means we don't work without
    Bryan> CONFIG_PCI_MSI.  That is, unless there's some other way to
    Bryan> get the vector that I don't know about (entirely likely).

OK, fair enough.  But that's a quirk of the x86 architecture that
you're pretty tied to -- you don't actually need MSI, you just need
the interrupt numbering that is enabled on x86 with that config option.

Since Niagara boxes don't have HT anyway it's kind of a moot point.
Although I wonder what you would have to do to make your device work
with something like the MIPS SoCs that have HT...

 - R.
