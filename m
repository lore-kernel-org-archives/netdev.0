From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: [ofa-general] Re: [PATCH 0/26] Reliable Datagram Sockets (RDS),
	take 2
Date: Wed, 25 Feb 2009 11:46:00 +0200
Message-ID: <49A51358.4080408@Voltaire.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>	<20090224.232814.227017310.davem@davemloft.net>	<49A4FB79.1090809@voltaire.com>
	<20090225.000628.108688119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090225.000628.108688119.davem@davemloft.net>
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

David Miller wrote:
> It's making real sockets, using the real networking stack,
> using up real IP port/address pairs recognized by the rest
> of the real networking stack, and doing RDMA over that connection.

The only usage of the network stack done by the RDMA stack (at its rdma connection manager) on behalf of protocols such as RDS is for address resolution. This practice of sending ARPs is supported by the mainline kernel for long time and common also among other technologies / drivers.

Or.
