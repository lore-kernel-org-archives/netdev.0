From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFT PATCH v3 00/12] Cleanup and extension of netdev features
Date: Fri, 26 Aug 2011 20:41:55 +0200
Message-ID: <20110826184155.GA14744@rere.qmqm.pl>
References: <cover.1308758435.git.mirq-linux@rere.qmqm.pl>
 <4E569CC8.9040605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:56161 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710Ab1HZSl5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Aug 2011 14:41:57 -0400
Content-Disposition: inline
In-Reply-To: <4E569CC8.9040605@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2011 at 12:04:40PM -0700, Ben Greear wrote:
> On 06/22/2011 09:04 AM, Micha=B3 Miros=B3aw wrote:
> >v3 of a feature handling cleanup and extension series. For testing, =
you
> >might want user-space ethtool patched with:
> >http://patchwork.ozlabs.org/patch/96374/
> It looks like this is not in net-next yet...any hope of this
> going in soon?

It's because the series depends on finishing conversions of all drivers
to ndo_fix/set_features. e1000e, igbvf, ixgb, ixgbevf are pending.

BTW, Jeff, what is the status of those conversions? Last version of ixg=
be
patch from Donald Skidmore (sent about a month ago) was mostly ready II=
UC.

Best Regards,
Micha=B3 Miros=B3aw
