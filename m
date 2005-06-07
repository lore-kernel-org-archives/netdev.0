From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 07 Jun 2005 13:21:59 -0700 (PDT)
Message-ID: <20050607.132159.35660612.davem@davemloft.net>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@osdl.org, mitch.a.williams@intel.com,
        mchan@broadcom.com, buytenh@wantstofly.org, jdmason@us.ibm.com,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: john.ronciak@intel.com
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Ronciak, John" <john.ronciak@intel.com>
Date: Tue, 7 Jun 2005 09:23:32 -0700

> There also seems to be some misconceptions about changing the weight
> value.  It actually improves the performance of other drivers as well.
> Not as much as it improves the e1000 performance but it does seem to
> help others as well.

One reason it helps e1000 more, which Robert Olsson mentioned, could
be the HW irq mitigation settings used by the e1000 driver.  Lowering
these would be a good test.
