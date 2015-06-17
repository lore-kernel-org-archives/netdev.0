From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v2 1/3] net: mvneta: introduce compatible string
 "marvell, armada-xp-neta"
Date: Wed, 17 Jun 2015 17:01:12 +0000
Message-ID: <20150617170112.GD2917@io.lakedaemon.net>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
 <1434547162-6275-2-git-send-email-simon.guinot@sequanux.org>
 <55818E64.20007@free-electrons.com>
 <55818F10.8030304@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Guinot <simon.guinot@sequanux.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55818F10.8030304@free-electrons.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

On Wed, Jun 17, 2015 at 05:15:28PM +0200, Gregory CLEMENT wrote:
> On 17/06/2015 17:12, Gregory CLEMENT wrote:
> > On 17/06/2015 15:19, Simon Guinot wrote:
> >> The mvneta driver supports the Ethernet IP found in the Armada 370, XP,
> >> 380 and 385 SoCs. Since at least one more hardware feature is available
> >> for the Armada XP SoCs then a way to identify them is needed.
> >>
> >> This patch introduces a new compatible string "marvell,armada-xp-neta".
> > 
> > Let's be future proof by going further. I would like to have an compatible string
> > for each SoC even if we currently we don't use them.

I disagree with this.  We can't predict what incosistencies we'll discover in
the future.  We should only assign new compatible strings based on known IP
variations when we discover them.  This seems fraught with demons since we
can't predict the scope of affected IP blocks (some steppings of one SoC, three
SoCs plus two steppings of a fourth, etc)

imho, the 'future-proofing' lies in being specific as to the naming of the
compatible strings against known hardware variations at the time.

thx,

Jason.
