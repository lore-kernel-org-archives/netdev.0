From: jamal <hadi@cyberus.ca>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: 07 Dec 2004 23:27:25 -0500
Message-ID: <1102480044.1050.9.camel@jzny.localdomain>
References: <1102380430.6103.6.camel@buffy>
	 <20041206224441.628e7885.akpm@osdl.org>
	 <1102422544.1088.98.camel@jzny.localdomain> <41B5E188.5050800@trash.net>
	 <20041207170748.GF1371@postel.suug.ch>  <41B5E722.2080600@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Andrew Morton <akpm@osdl.org>,
	Thomas Cataldo <tomc@compaqnet.fr>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261787AbULHE1f@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41B5E722.2080600@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-07 at 12:23, Patrick McHardy wrote:

> Either one is fine with me, although I would prefer to see
> the number of ifdefs in this area going down, not up :)

You guys pick one or other or a mix. I run 4 base testcases for the
policer typically:

1) Old kernel, uptodate TC - MUST pass
2) old kernel, old tc (trivial - expected to pass).
3) New Kernel, uptodate TC - MUST pass
4) New Kernel, uptodate TC - MUST pass (although trivial)

Try both setting, dumping then deleting policies.

If these tests pass, please push patch to Dave. 

cheers,
jamal
