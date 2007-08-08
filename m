From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Wed, 08 Aug 2007 18:53:46 -0400
Message-ID: <1186613626.5152.48.camel@localhost>
References: <20070808.034900.85820906.davem@davemloft.net>
	<20070808134247.GA9942@gondor.apana.org.au>
	<1186586075.5155.27.camel@localhost>
	<20070808.152240.56052317.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, mcarlson@broadcom.com, netdev@vger.kernel.org,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, jeff@garzik.org,
	shemminger@linux-foundation.org, kaber@trash.net, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808.152240.56052317.davem@davemloft.net>
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

On Wed, 2007-08-08 at 15:22 -0700, David Miller wrote:

> The driver path, however, does not exist on an island and what
> we care about is the final result with the changes running
> inside the full system.
> 
> So, to be honest, besides for initial internal development
> feedback, the isolated tests only have minimal merit and
> it's the full protocol tests that are really interesting.

But you cant go there if cant show the path which is supposedly improved
has indeed improved;-> I would certainly agree with you that if it
doesnt prove consistently useful with protocols it has no value
(remember thats why i never submitted these patches all this time).
We just need better analysis of the results - i cant ignore that the
selection of the clock sources for example gives me different results
and that when i boot i cant be guaranteed the same clock source. I cant
ignore the fact that i get different results when i use a different
congestion control algorithm. And none of this has to do with the
batching patches.

I am using UDP at the moment because it is simpler to analyze. And yes,
it would be "an interesting idea that gets shelved" if we cant achieve
any of the expected goals. We've shelved ideas before. BTW, read the
little doc i wrote on the dev->prep_xmit() you may find it interesting.

cheers,
jamal
