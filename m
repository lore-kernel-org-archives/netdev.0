From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Thu, 23 Aug 2007 20:34:25 -0700
Message-ID: <20070823203425.2a32fb3f@freepuppy.rosehill.hemminger.net>
References: <46CC6DD1.5020105@hp.com>
	<20070822.132145.90824527.davem@davemloft.net>
	<1187906650.4279.16.camel@localhost>
	<20070823.153047.99173582.davem@davemloft.net>
	<1187908702.4279.36.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com, kaber@trash.net,
	jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, johnpol@2ka.mipt.ru,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1187908702.4279.36.camel@localhost>
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

On Thu, 23 Aug 2007 18:38:22 -0400
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2007-23-08 at 15:30 -0700, David Miller wrote:
> > From: jamal <hadi@cyberus.ca>
> > Date: Thu, 23 Aug 2007 18:04:10 -0400
> > 
> > > Possibly a bug - but you really should turn off TSO if you are doing
> > > huge interactive transactions (which is fair because there is a clear
> > > demarcation).
> > 
> > I don't see how this can matter.
> > 
> > TSO only ever does anything if you accumulate more than one MSS
> > worth of data.
> 
> I stand corrected then.
> 
> cheers,
> jamal
> 

For most normal Internet TCP connections, you will see only 2 or 3 packets per TSO
because of ACK clocking. If you turn off delayed ACK on the receiver it
will be even less.

A current hot topic of research is reducing the number of ACK's to make TCP
work better over asymmetric links like 3G.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
