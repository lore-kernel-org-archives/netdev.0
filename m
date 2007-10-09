From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 19:46:36 -0700 (PDT)
Message-ID: <20071008.194636.56034897.davem@davemloft.net>
References: <470AD5D7.1070000@garzik.org>
	<20071008.184126.124062865.davem@davemloft.net>
	<470AE373.9020207@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net
To: jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <470AE373.9020207@garzik.org>
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

From: Jeff Garzik <jeff@garzik.org>
Date: Mon, 08 Oct 2007 22:12:03 -0400

> I'm interested in working on a load balancer function that approximates
> 
> 	skb->queue_mapping = smp_processor_id()
> 
> I'd be happy to code and test in that direction, based on your lib.

It's the second algorithm that will be available :-)  Just add
a "% num_tx_queues" to the result.

> IMO the net driver really should provide a hint as to what it wants.
> 
> 8139cp and tg3 would probably prefer multiple TX queue behavior to match 
> silicon behavior -- strict prio.
> 
> And I'll volunteer to write the net driver code for that, if people want 
> to see how things would look for that type of hardware packet scheduling.

Ok.
