From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Tue, 25 Sep 2007 18:43:38 -0400
Message-ID: <1190760218.4244.35.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51122@orsmsx414.amr.corp.intel.com>
	<1190674298.4264.24.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>
	<1190677099.4264.37.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A5151B@orsmsx414.amr.corp.intel.com>
	<20070924171411.36494656@freepuppy.rosehill>
	<1190726138.4264.105.camel@localhost>
	<20070925082457.6fec30d6@freepuppy.rosehill>
	<1190758491.4244.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, kumarkr@linux.ibm.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com, "Waskiewicz Jr,
	Peter P" <peter.p.waskiewicz.jr@intel.com>,
	mcarlson@broadcom.com, kaber@trash.net, randy.dunlap@oracle.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, jeff@garzik.org,
	sri@us.ibm.com, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1190758491.4244.15.camel@localhost>
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

On Tue, 2007-25-09 at 18:15 -0400, jamal wrote:

> A further optimization i made was to reduce the time it takes to hold
> the tx lock at the driver by moving gunk that doesnt need lock-holding
> into the new method dev->hard_end_xmit() (refer to patch #2)

Sorry, that should have read dev->hard_prep_xmit()

cheers,
jamal
