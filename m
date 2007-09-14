From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH 0/10 REV5] Implement skb batching and
	support in IPoIB/E1000
Date: Fri, 14 Sep 2007 16:49:07 +0400
Message-ID: <20070914124906.GE18517@2ka.mipt.ru>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	netdev@vger.kernel.org, rdreier@cisco.com, hadi@cyberus.ca,
	kaber@trash.net, randy.dunlap@oracle.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	mcarlson@broadcom.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
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

Hi Krishna.

On Fri, Sep 14, 2007 at 02:30:58PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> --------
> The retransmission problem reported earlier seems to happen when mthca is
> used as the underlying device, but when I tested ehca the retransmissions
> dropped to normal levels (around 2 times the regular code). The performance
> improvement is around 55% for TCP.

And what about latency for this patchset?

-- 
	Evgeniy Polyakov
