From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: 07 Dec 2004 23:41:53 -0500
Message-ID: <1102480913.1049.24.camel@jzny.localdomain>
References: <1102380430.6103.6.camel@buffy>
	 <20041206224441.628e7885.akpm@osdl.org>
	 <1102422544.1088.98.camel@jzny.localdomain> <41B5E188.5050800@trash.net>
	 <20041207170748.GF1371@postel.suug.ch>  <41B5E722.2080600@trash.net>
	 <1102480044.1050.9.camel@jzny.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Andrew Morton <akpm@osdl.org>,
	Thomas Cataldo <tomc@compaqnet.fr>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262018AbULHEmG@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <1102480044.1050.9.camel@jzny.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


BTW, old kernel in this case implies one that does not support tc
actions at all. So pick something like 2.4.28.
New is whatever 2.6.x with patch.
Old tc is something that for example ships with redhat
new tc is whatever one is patched.

Supplementary tests are: in 2.6.x to compile the policer
in two different ways a) via tc actions and b) using the old scheme
which is understood by "old" tc. Repeat the tests i described earlier
with b) pretending to be "old" kernel.

Infact come to think of it i would also prefer to have the suplementary
tests run as well.
If you guys have no cycles, please pass the patch to me and i will test
on the weekend.

cheers,
jamal

On Tue, 2004-12-07 at 23:27, jamal wrote:
> On Tue, 2004-12-07 at 12:23, Patrick McHardy wrote:
> 
> > Either one is fine with me, although I would prefer to see
> > the number of ifdefs in this area going down, not up :)
> 
> You guys pick one or other or a mix. I run 4 base testcases for the
> policer typically:
> 
> 1) Old kernel, uptodate TC - MUST pass
> 2) old kernel, old tc (trivial - expected to pass).
> 3) New Kernel, uptodate TC - MUST pass
> 4) New Kernel, uptodate TC - MUST pass (although trivial)
> 
> Try both setting, dumping then deleting policies.
> 
> If these tests pass, please push patch to Dave. 
> 
> cheers,
> jamal
> 
