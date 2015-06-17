From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 1/3] net: mvneta: introduce compatible string
 "marvell, armada-xp-neta"
Date: Wed, 17 Jun 2015 22:43:12 +0200
Message-ID: <20150617224312.3bfc80d9@free-electrons.com>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
	<1434547162-6275-2-git-send-email-simon.guinot@sequanux.org>
	<55818E64.20007@free-electrons.com>
	<55818F10.8030304@free-electrons.com>
	<20150617170112.GD2917@io.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150617170112.GD2917@io.lakedaemon.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason,

On Wed, 17 Jun 2015 17:01:12 +0000, Jason Cooper wrote:

> I disagree with this.  We can't predict what incosistencies we'll discover in
> the future.  We should only assign new compatible strings based on known IP
> variations when we discover them.  This seems fraught with demons since we
> can't predict the scope of affected IP blocks (some steppings of one SoC, three
> SoCs plus two steppings of a fourth, etc)
> 
> imho, the 'future-proofing' lies in being specific as to the naming of the
> compatible strings against known hardware variations at the time.

Except that this clearly doesn't work, and the case raised by Simon is
a perfect illustration of why planning ahead is beneficial. We already
had the issue several times on mvebu platforms, so it should really
become the rule to have one compatible string specific to the actual
SoC in the list of compatible strings.

Not doing so requires breaking DT backward compatibility more often, so
wanting DT backward compatibility and not wanting to plan ahead is a
bit antagonist. But I personally don't care much about DT backward
compatibility, and I've explained numerous times why, so in the end I
don't really care much.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
