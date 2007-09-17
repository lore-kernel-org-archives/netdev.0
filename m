From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Mon, 17 Sep 2007 14:47:42 -0700
Message-ID: <ada1wcxnev5.fsf@cisco.com>
References: <OF1B5CCF10.3CE4B194-ON87257356.00661AD2-88257356.0065F05E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, netdev-owner@vger.kernel.org
To: Shirley Ma <xma@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OF1B5CCF10.3CE4B194-ON87257356.00661AD2-88257356.0065F05E@us.ibm.com>
	(Shirley Ma's message of "Fri, 14 Sep 2007 11:36:12 -0700")
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

 > > IPoIB CM handles this properly by gathering together single pages in
 > > skbs' fragment lists.

 > Then can we reuse IPoIB CM code here?

Yes, if possible, refactoring things so that the rx skb allocation
code becomes common between CM and non-CM would definitely make sense.
