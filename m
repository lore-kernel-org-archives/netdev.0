From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Re: [PATCH 6/6] IB: userspace support for RDMA
	connection manager
Date: Mon, 06 Mar 2006 15:40:56 -0800
Message-ID: <adapskz3zw7.fsf@cisco.com>
References: <aday7zn432b.fsf@cisco.com>
	<20060306.143901.26500391.davem@davemloft.net>
	<adau0ab42ni.fsf@cisco.com>
	<20060306.145053.129802994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060306.145053.129802994.davem@davemloft.net> (David S.
	Miller's message of "Mon, 06 Mar 2006 14:50:53 -0800 (PST)")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Roland> I should look into getting some niagara machines to test
    Roland> with -- with PCIe slots they should actually be good for
    Roland> IB testing.

    David> You'll be cpu limited until we have Van Jacobson net
    David> channels.

For IPoIB maybe but not for native IB which offloads all transport to
the HCA... I'd be surprised if the bottleneck were anywhere other than
the bus, even on niagara.

    David> Also, since our existing Linux "generic" MSI code is so
    David> riddled with x86'isms (it was written by an Intel person,
    David> so this is just the status quo), it will be a while before
    David> MSI interrupts are supported on sparc64.

Yeah, I've always wanted to make the MSI stuff generic and handle the
embedded ppc chips that have MSI, but I've never had a good enough
reason to really work on it -- it's just been at the level of "that
would be fun."  Now that IBM cares I hope it will get done soon.

Anyway IB works fine with standard INTx interrupts -- MSI is just icing.

The Niagara boxes seem like a fun toy if I can get budget for it --
and 32 threads are probably good for flushing out SMP races.

 - R.
