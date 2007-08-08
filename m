From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Wed, 08 Aug 2007 15:01:37 -0700 (PDT)
Message-ID: <20070808.150137.50597736.davem@davemloft.net>
References: <20070808.034900.85820906.davem@davemloft.net>
	<OF09D78F6D.0A3EBAD3-ON65257331.003CB0E9-65257331.003D526B@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net,
	herbert@gondor.apana.org.au
To: krkumar2@in.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OF09D78F6D.0A3EBAD3-ON65257331.003CB0E9-65257331.003D526B@in.ibm.com>
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

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Wed, 8 Aug 2007 16:39:47 +0530

> What do you generally think of the patch/implementation ? :)

We have two driver implementation paths on recieve and now
we'll have two on send, and that's not a good trend.

In an ideal world all the drivers would be NAPI and netif_rx()
would only be used by tunneling drivers and similar in the
protocol layers.  And likewise all sends would go through
->hard_start_xmit().

If you can come up with a long term strategy that gets rid of
the special transmit method, that'd be great.

We should make Linux network drivers easy to write, not more difficult
by constantly adding most interfaces than we consolidate.
