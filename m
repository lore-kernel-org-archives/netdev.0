From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 19:47:06 -0700 (PDT)
Message-ID: <20071008.194706.97044591.davem@davemloft.net>
References: <20071008.184126.124062865.davem@davemloft.net>
	<1191896071.4373.156.camel@localhost>
	<20071009021620.GA14917@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jeff@garzik.org, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, gaagaan@gmail.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, shemminger@linux-foundation.org,
	kaber@trash.net, sri@us.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009021620.GA14917@gondor.apana.org.au>
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

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 9 Oct 2007 10:16:20 +0800

> On Mon, Oct 08, 2007 at 10:14:30PM -0400, jamal wrote:
> >
> > You forgot QDISC_RUNNING Dave;-> the above cant happen. 
> > Essentially at any one point in time, we are guaranteed that we can have
> > multiple cpus enqueueing but only can be dequeueing (the one that
> > managed to grab QDISC_RUNNING) i.e multiple producers to the qdisc queue
> > but only one consumer. Only the dequeuer has access to the txlock.
> 
> Good point.  You had me worried for a sec :)
> 
> Dave, Jamal's patch is fine as it is and doesn't actually create
> any packet reordering.

Ok, then, I'll un-revert. :-)
