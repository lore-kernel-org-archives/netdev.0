From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] ethernet/arc/arc_emac - Add new driver
Date: Sat, 15 Jun 2013 13:12:20 +0200
Message-ID: <20130615111220.GB14242@electric-eye.fr.zoreil.com>
References: <1371134239-4531-1-git-send-email-abrodkin@synopsys.com>
 <20130613221946.GA16632@electric-eye.fr.zoreil.com>
 <4881796E12491D4BB15146FE0209CE643F5E3A07@DE02WEMBXB.internal.synopsys.com>
 <20130614192704.GA4857@electric-eye.fr.zoreil.com>
 <4881796E12491D4BB15146FE0209CE643F5E5730@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Joe Perches <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F5E5730@DE02WEMBXB.internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Brodkin <Alexey.Brodkin@synopsys.com> :
[...]
> If my comment doesn't make sense to you or I misunderstood your message 
> could you please add more clarifications for your idea?

Sorry, I temporarily forgot it was the descriptor ring itself. :o/

It would make sense to qualify the descriptor members as __{le/be}32 then
use them with proper cpu_to_{le/be} wrappers _and_ mapping addresses
instead of direct skb->data assignment.

-- 
Ueimor
