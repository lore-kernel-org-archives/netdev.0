From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH 0/26] Reliable Datagram Sockets
	(RDS), take 2
Date: Wed, 25 Feb 2009 00:06:28 -0800 (PST)
Message-ID: <20090225.000628.108688119.davem@davemloft.net>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	<20090224.232814.227017310.davem@davemloft.net>
	<49A4FB79.1090809@voltaire.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: ogerlitz@voltaire.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <49A4FB79.1090809@voltaire.com>
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

From: Or Gerlitz <ogerlitz@voltaire.com>
Date: Wed, 25 Feb 2009 10:04:09 +0200

> Can you elaborate a bit further, I wasn't sure to follow if your
> comment was related to the inclusion of iwarp or to something else.

It's making real sockets, using the real networking stack,
using up real IP port/address pairs recognized by the rest
of the real networking stack, and doing RDMA over that
connection.

That's not allowed.

We always said that if these RDMA things are in the tree,
they should use their own IP addresses and that are not
visible to the real Linux networking stack.
