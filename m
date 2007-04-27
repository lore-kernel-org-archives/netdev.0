From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Fri, 27 Apr 2007 16:39:34 -0700 (PDT)
Message-ID: <20070427.163934.106263903.davem@davemloft.net>
References: <46327A07.1000404@hp.com>
	<6.1.2.0.2.20070427153952.13fc7d08@mail.llnl.gov>
	<4632894D.40705@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lawver1@llnl.gov, netdev@vger.kernel.org, mst@dev.mellanox.co.il,
	general@lists.openfabrics.org
To: rick.jones2@hp.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <4632894D.40705@hp.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 27 Apr 2007 16:37:49 -0700

> Large Receive Offload (LRO) is enabled by default.  This will
> interfere with forwarding TCP traffic.  If you plan to forward TCP
> traffic (using the host with the Myri10GE NIC as a router or bridge),
> you must disable LRO.  To disable LRO, load the myri10ge driver
> with myri10ge_lro set to 0:

LRO should be disabled by default if the driver does this.  This is a
major and unacceptable bug.

Thanks for pointing this out Rick.
