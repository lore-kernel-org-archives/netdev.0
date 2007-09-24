From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] RE: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Mon, 24 Sep 2007 19:38:19 -0400
Message-ID: <1190677099.4264.37.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51122@orsmsx414.amr.corp.intel.com>
	<1190674298.4264.24.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, kumarkr@linux.ibm.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com, mcarlson@broadcom.com,
	kaber@trash.net, randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>
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

On Mon, 2007-24-09 at 15:57 -0700, Waskiewicz Jr, Peter P wrote:

> I've looked at that as a candidate to use.  The lock for enqueue would
> be needed when actually placing the skb into the appropriate software
> queue for the qdisc, so it'd be quick.

The enqueue is easy to comprehend. The single device queue lock should
suffice. The dequeue is interesting:
Maybe you can point me to some doc or describe to me the dequeue aspect;
are you planning to have an array of txlocks per, one per ring?
How is the policy to define the qdisc queues locked/mapped to tx rings? 

cheers,
jamal
