From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 08/12] ixgbe: using is_zero_ether_addr() to simplify
 the code
Date: Tue, 23 Oct 2012 12:35:47 -0700
Message-ID: <1351020947.7502.51.camel@joe-AO722>
References: <1350966385-19020-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350966385-19020-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350967518.7502.32.camel@joe-AO722>
	 <1350969467.2135.11.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42461 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756922Ab2JWTft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 15:35:49 -0400
In-Reply-To: <1350969467.2135.11.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-22 at 22:17 -0700, Jeff Kirsher wrote:
> On Mon, 2012-10-22 at 21:45 -0700, Joe Perches wrote:
> > On Mon, 2012-10-22 at 21:26 -0700, Jeff Kirsher wrote:
> > > From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > > Using is_zero_ether_addr() to simplify the code.
> > []
> > > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
> > []
> > > @@ -1778,8 +1778,7 @@ s32 ixgbe_validate_mac_addr(u8 *mac_addr)
> > []
> > > -	else if (mac_addr[0] == 0 && mac_addr[1] == 0 && mac_addr[2] == 0 &&
> > > -	         mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0)
> > > +	else if (is_zero_ether_addr(mac_addr))
> > 
> > This means the more comprehensive simplifying patch
> > I submitted doesn't apply.  Easy to fix up though.
> >
[]
>  Want me to
> send you the fixed up patch so that you can confirm my fixes?

Nope, no worries, I'm sure you'll do the right thing.
I just wanted to alert you about it.
