From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload feature
Date: Thu, 02 Jun 2005 16:22:04 -0700 (PDT)
Message-ID: <20050602.162204.68041633.davem@davemloft.net>
References: <20050527.120215.26278001.davem@davemloft.net>
	<003201c567c9$73322240$3910100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, raghavendra.koushik@neterion.com,
        leonid.grossman@neterion.com, ananda.raju@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@neterion.com
In-Reply-To: <003201c567c9$73322240$3910100a@pc.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Date: Thu, 2 Jun 2005 16:18:55 -0700

> Since there seems to be pros and cons for both the approaches, we are
> planning
> to submit two separate patches(one for each approach). These patches also
> include the ethtool changes. In terms of performance, we did not observe any
> diff between the two approaches although the first approach(using SG)
> minimizes
> coalescing in driver.

Ok.  I think minimizing driver specific work is probably going
to make the SG approach more desirable, but we'll see.

> Also, some changes will be required in the ethtool user-level utility.
> I'm not sure if this is the right forum to submit patches for the ethtool
> utility as well..

Making sure jgarzik@pobox.com gets the patch is usually the way
to go wrt. ethtool submissions.
