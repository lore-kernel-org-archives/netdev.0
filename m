From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Wed, 08 Aug 2007 03:49:00 -0700 (PDT)
Message-ID: <20070808.034900.85820906.davem@davemloft.net>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, mcarlson@broadcom.com, jeff@garzik.org,
	hadi@cyberus.ca, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, sri@us.ibm.com
To: krkumar2@in.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
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

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 08 Aug 2007 15:01:14 +0530

> RESULTS: The performance improvement for TCP No Delay is in the range of -8%
> 	to 320% (with -8% being the sole negative), with many individual tests
> 	giving 50% or more improvement (I think it is to do with the hw slots
> 	getting full quicker resulting in more batching when the queue gets
> 	woken). The results for TCP is in the range of -11% to 93%, with most
> 	of the tests (8/12) giving improvements.

Not because I think it obviates your work, but rather because I'm
curious, could you test a TSO-in-hardware driver converted to
batching and see how TSO alone compares to batching for a pure
TCP workload?

I personally don't think it will help for that case at all as
TSO likely does better job of coalescing the work _and_ reducing
bus traffic as well as work in the TCP stack.
