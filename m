From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] cfg80211: firmware and hardware version
Date: Thu, 01 Oct 2009 16:33:19 +0100
Message-ID: <1254411199.2735.4.camel@achroite>
References: <20090924180048.14503.9579.stgit@tikku>
	 <43e72e890909241320j592e347die8a14f8bdd962ffb@mail.gmail.com>
	 <20090925044258.GA2722@tuxdriver.com>
	 <da94abde0909250947k5084db85vccafe0d3e74e2ecf@mail.gmail.com>
	 <43e72e890909250953r1714c79bsa679b96ca6f5797@mail.gmail.com>
	 <20091001011340.GA3123@tuxdriver.com> <87fxa3qjt2.fsf@purkki.valot.fi>
	 <20091001151820.GA2895@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kalle.valo@iki.fi>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:44205 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965AbZJAPdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 11:33:18 -0400
In-Reply-To: <20091001151820.GA2895@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-01 at 11:18 -0400, John W. Linville wrote:
[...]
> > But here are the features which I doubt we will ever use:
> > 
> >         ethtool -s|--change DEVNAME     Change generic options
> >                 [ speed %%d ]
> >                 [ duplex half|full ]
> >                 [ port tp|aui|bnc|mii|fibre ]
> >                 [ autoneg on|off ]
> >                 [ advertise %%x ]
> >                 [ phyad %%d ]
> >                 [ xcvr internal|external ]
> >                 [ wol p|u|m|b|a|g|s|d... ]
> >                 [ sopass %%x:%%x:%%x:%%x:%%x:%%x ]
> >                 [ msglvl %%d ] 
> >         ethtool -a|--show-pause DEVNAME Show pause options
> >         ethtool -A|--pause DEVNAME      Set pause options
> >                 [ autoneg on|off ]
> >                 [ rx on|off ]
> >                 [ tx on|off ]
> 
> I agree that the above are ethernet-specific.
[...]

Message level isn't and WoL arguably isn't.  It's a shame that these
original ethtool settings are still bundled together...

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

