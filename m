From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Re: [PATCH 6/6] IB: userspace support for
	RDMA connection manager
Date: Mon, 06 Mar 2006 14:50:53 -0800 (PST)
Message-ID: <20060306.145053.129802994.davem@davemloft.net>
References: <aday7zn432b.fsf@cisco.com>
	<20060306.143901.26500391.davem@davemloft.net>
	<adau0ab42ni.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
In-Reply-To: <adau0ab42ni.fsf@cisco.com>
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

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 06 Mar 2006 14:41:21 -0800

> I should look into getting some niagara machines to test with -- with
> PCIe slots they should actually be good for IB testing.

You'll be cpu limited until we have Van Jacobson net channels.

Also, since our existing Linux "generic" MSI code is so riddled with
x86'isms (it was written by an Intel person, so this is just the
status quo), it will be a while before MSI interrupts are supported on
sparc64.

I haven't gotten around to working on that problem yet, and PPC needs
this work too as they now have MSI capable PCI controllers.
