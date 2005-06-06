From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Mon, 6 Jun 2005 13:29:50 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <mchan@broadcom.com>, <hadi@cyberus.ca>, <buytenh@wantstofly.org>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, <jdmason@us.ibm.com>,
        <shemminger@osdl.org>, <netdev@oss.sgi.com>,
        <Robert.Olsson@data.slu.se>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 	If you force the e1000 driver to do RX replenishment every N
> 	packets it should reduce the packet drops the same (in the
> 	single NIC case) as if you reduced the dev->weight to that
> 	same value N.

But this isn't what we are seeing.  Even if we just reduce the weight
value to 32 from 64, all of the drops go away.  So there seems to be
other things affecting this.

We are just talking about single NIC testing at this point.  I agree
that single and multi-NIC results different issues and we will need to
test this as well with whatever we come up with out of this.

I also like your idea about the weight value being adjusted based on
real work done using some measurable metric.  This seems like a good
path to explore as well.

Cheers,
John
