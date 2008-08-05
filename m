From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] catch up device stats when multicast
	>total frames
Date: Tue, 5 Aug 2008 19:12:01 +0200
Message-ID: <200808051912.02053.netdev@axxeo.de>
References: <20080805131610.GC22123@hmsreliant.think-freely.org>
	<36D9DB17C6DE9E40B059440DB8D95F5205C8FA8C@orsmsx418.amr.corp.intel.com>
	<20080805165323.GD22123@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	"Kirsher,  Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080805165323.GD22123@hmsreliant.think-freely.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi all,

Neil Horman schrieb:
> Agreed, theres no great solution here.

There maybe:
1. store software counters counted in software in stat_soft_last
2. store software counters counted in hardware in stat_hard_last
3. diff them after getting the fresh counters from hardware and software
4. wait for any "get statistic" request as done with hardware counters today
5. store the combination, taking "unseen packets" into account, 
    as the real netstat
6. goto 1.

What do you think?


Best Regards

Ingo Oeser

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
