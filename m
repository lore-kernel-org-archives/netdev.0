From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Thu, 23 Aug 2007 18:04:10 -0400
Message-ID: <1187906650.4279.16.camel@localhost>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>
	<20070821.212229.82050253.davem@davemloft.net>
	<46CC6DD1.5020105@hp.com>
	<20070822.132145.90824527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, kaber@trash.net, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070822.132145.90824527.davem@davemloft.net>
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

On Wed, 2007-22-08 at 13:21 -0700, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Wed, 22 Aug 2007 10:09:37 -0700
> 
> > Should it be any more or less worrysome than small packet
> > performance (eg the TCP_RR stuff I posted recently) being rather
> > worse with TSO enabled than with it disabled?
> 
> That, like any such thing shown by the batching changes, is a bug
> to fix.

Possibly a bug - but you really should turn off TSO if you are doing
huge interactive transactions (which is fair because there is a clear
demarcation).
The litmus test is the same as any change that is supposed to improve
net performance - it has to demonstrate it is not intrusive and that it
improves (consistently) performance. The standard metrics are
{throughput, cpu-utilization, latency} i.e as long as one improves and
others remain zero, it would make sense. Yes, i am religious for
batching after all the invested sweat (and i continue to work on it
hoping to demystify) - the theory makes a lot of sense.
 
cheers,
jamal
