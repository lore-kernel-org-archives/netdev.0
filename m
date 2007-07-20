From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Fri, 20 Jul 2007 16:54:23 +0400
Message-ID: <20070720125423.GB13468@2ka.mipt.ru>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	sri@us.ibm.com, hadi@cyberus.ca, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
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

On Fri, Jul 20, 2007 at 12:01:49PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> After fine-tuning qdisc and other changes, I modified IPoIB to use this API,
> and now get good gains. Summary for TCP & No Delay: 1 process improves for
> all cases from 1.4% to 49.5%; 4 process has almost identical improvements
> from -1.7% to 59.1%; 16 process case also improves in the range of -1.2% to
> 33.4%; while 64 process doesn't have much improvement (-3.3% to 12.4%). UDP
> was tested with 1 process netperf with small increase in BW but big
> improvement in Service Demand. Netperf latency tests show small drop in
> transaction rate (results in separate attachment).

What about round-robin tcp time and latency test? In theory such batching
mode should not change that timings, but practice can show new aspects.
I will review code later this week (likely tomorrow) and if there will
be some issues return back.

-- 
	Evgeniy Polyakov
