From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Fri, 20 Jul 2007 18:32:50 +0530
Message-ID: <OF7D4124DB.BCA4AB16-ON6525731E.00475350-6525731E.0047AC06@in.ibm.com>
References: <20070720125423.GB13468@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, mcarlson@broadcom.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	davem@davemloft.net, sri@us.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720125423.GB13468@2ka.mipt.ru>
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

Hi Evgeniy,

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 07/20/2007 06:24:23 PM:

> > After fine-tuning qdisc and other changes, I modified IPoIB to use this
API,
> > and now get good gains. Summary for TCP & No Delay: 1 process improves
for
> > all cases from 1.4% to 49.5%; 4 process has almost identical
improvements
> > from -1.7% to 59.1%; 16 process case also improves in the range of
-1.2% to
> > 33.4%; while 64 process doesn't have much improvement (-3.3% to 12.4%).
UDP
> > was tested with 1 process netperf with small increase in BW but big
> > improvement in Service Demand. Netperf latency tests show small drop in
> > transaction rate (results in separate attachment).
>
> What about round-robin tcp time and latency test? In theory such batching
> mode should not change that timings, but practice can show new aspects.
> I will review code later this week (likely tomorrow) and if there will
> be some issues return back.

I had run RR test quite some time back and don't have the result at this
time,
other than remembering it was almost the same as the original. As I am
running
some tests on those systems at this time, I can send the results of RR
tomorrow.

Thanks,

- KK
