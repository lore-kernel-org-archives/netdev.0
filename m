From: Roland Dreier <roland@topspin.com>
Subject: Re: TCP IP Offloading Interface
Date: 15 Jul 2003 18:51:39 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <52fzl7s0gk.fsf@topspin.com>
References: <E3738FB497C72449B0A81AEABE6E713C027A43@STXCHG1.simpletech.com>
	<20030714225133.18395b69.davem@redhat.com>
	<1058329895.1796.28.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Jordi Ros <jros@xiran.com>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@oss.sgi.com, alan@storlinksemi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: hadi@cyberus.ca
In-Reply-To: <1058329895.1796.28.camel@jzny.localdomain>
List-Id: netdev.vger.kernel.org

    jamal> What about infiniband which has all this built in
    jamal> offloading?

We're seeing some pretty good numbers (well above 5 Gb/sec, basically
PCI-X 64bit/133MHz limited) with sockets direct (SDP) on top of
InfiniBand.  This is running standard sockets applications, just using
the AIO patches for kernel 2.4.  Latency is also much better than TCP
on top of ethernet, although this is mostly just due to the
underlying transport.

 - Roland
