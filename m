From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH 0/26] Reliable Datagram Sockets (RDS),
	take 2
Date: Wed, 25 Feb 2009 10:16:18 -0800
Message-ID: <adaeixmtma5.fsf@cisco.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	<20090224.232814.227017310.davem@davemloft.net>
	<49A4FB79.1090809@voltaire.com>
	<20090225.000628.108688119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090225.000628.108688119.davem@davemloft.net> (David Miller's
	message of "Wed, 25 Feb 2009 00:06:28 -0800 (PST)")
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

 > It's making real sockets, using the real networking stack,
 > using up real IP port/address pairs recognized by the rest
 > of the real networking stack, and doing RDMA over that
 > connection.
 > 
 > That's not allowed.
 > 
 > We always said that if these RDMA things are in the tree,
 > they should use their own IP addresses and that are not
 > visible to the real Linux networking stack.

How is what the RDS code is doing any different than what the (upstream)
NFS/RDMA and iSER code does?  It uses the same rdma_xxx() interfaces for
handling connections.

 - R.
