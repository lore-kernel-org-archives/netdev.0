From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Mon, 29 Sep 2003 15:46:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064846768.21551.15.camel@hades.cambridge.redhat.com>
References: <20030928225941.GW15338@fs.tum.de>
	 <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de>
	 <20030928233909.GG1039@conectiva.com.br> <20030929001439.GY15338@fs.tum.de>
	 <20030929003229.GM1039@conectiva.com.br>
	 <1064826174.29569.13.camel@hades.cambridge.redhat.com>
	 <20030929141548.GS1039@conectiva.com.br>
	 <200309291438.h8TEcVtH021550@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
        Adrian Bunk <bunk@fs.tum.de>, netdev@oss.sgi.com, davem@redhat.com,
        pekkas@netcore.fi, lksctp-developers@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200309291438.h8TEcVtH021550@turing-police.cc.vt.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-09-29 at 10:38 -0400, Valdis.Kletnieks@vt.edu wrote:
> No, this is the behavior we want, and we can write Kconfig help entries that
> explain it.
> 
> Anybody want to do a sanity check against CONFIG_IP6_NF_IPTABLES - that
> looks like another gotcha if it isn't implemented properly (it may be, I just haven't
> actually looked it over)?

In 2.7 we really should just stop the CONFIG_xxx_MODULE definitions
being available during builds of the static kernel.

-- 
dwmw2
