From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 15:37:05 -0700 (PDT)
Message-ID: <20071010.153705.94557376.davem@davemloft.net>
References: <20071010102331.GA10496@one.firstfloor.org>
	<20071010.034446.85819294.davem@davemloft.net>
	<1192021728.4853.17.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, jeff@garzik.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	andi@firstfloor.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net,
	mchan@broadcom.com, jagana@us.ibm.com
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1192021728.4853.17.camel@localhost>
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

From: jamal <hadi@cyberus.ca>
Date: Wed, 10 Oct 2007 09:08:48 -0400

> On Wed, 2007-10-10 at 03:44 -0700, David Miller wrote:
> 
> > I've always gotten very poor results when increasing the TX queue a
> > lot, for example with NIU the point of diminishing returns seems to
> > be in the range of 256-512 TX descriptor entries and this was with
> > 1.6Ghz cpus.
> 
> Is it interupt per packet? From my experience, you may find interesting
> results varying tx interupt mitigation parameters in addition to the
> ring parameters.
> Unfortunately when you do that, optimal parameters also depends on
> packet size. so what may work for 64B, wont work well for 1400B.

No, it was not interrupt per-packet, I was telling the chip to
interrupt me every 1/4 of the ring.
