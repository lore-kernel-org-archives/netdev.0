From: Olaf Kirch <okir@suse.de>
Subject: Re: [RFC] TCP congestion schedulers
Date: Tue, 22 Mar 2005 02:41:54 +0100
Message-ID: <20050322014154.GB4555@suse.de>
References: <20050225120814.5fa77b13@dxpl.pdx.osdl.net> <20050309210442.3e9786a6.davem@davemloft.net> <4230288F.1030202@ev-en.org> <20050310182629.1eab09ec.davem@davemloft.net> <20050311120054.4bbf675a@dxpl.pdx.osdl.net> <20050311201011.360c00da.davem@davemloft.net> <20050314151726.532af90d@dxpl.pdx.osdl.net> <m13bur5qyo.fsf@muc.de> <Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu> <423F627C.2060100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <423F627C.2060100@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 21, 2005 at 04:10:36PM -0800, Rick Jones wrote:
> I would put-forth netperf - but then I'm of course biased.  It is 

I think that was one of the benchmarks where the ia64 slowdown with
LSM was diagnosed; netperf suffered some 10-15% degradation. And that was
just with the capability module loaded, no fancy stuff going on.
After we hacked up LSM to inline the capability checks in the default
case, performance was back to normal.

We didn't bother to pin-point where the loss actually occured, but my
suspicion is the major offender was the per-skb check.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
