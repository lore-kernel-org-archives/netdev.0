From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC 1/2] igb: statistic optimization
Date: Wed, 22 Oct 2008 10:37:44 -0700
Message-ID: <48FF64E8.4050907@hp.com>
References: <20081021120935.1b3cea8d@extreme>
	<Pine.WNT.4.63.0810211224440.2736@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"jeffery.t.kirsher@intel.com" <jeffery.t.kirsher@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.WNT.4.63.0810211224440.2736@jbrandeb-desk.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> I don't think you want to put this in the code that can be called directly 
> from IOCTL from userspace.  This function can take a lot of cycles and 
> some silly applications like gkrellm call it quite frequently.  The 
> update_stats function will be called as part of the watchdog anyway, and 
> you already got the interesting stats for realtime with the tx and rx 
> bytes/packets.

On the flip side aren't there "out of phase" issues with pulling stats 
based on a timer vs something like a netstat -i 1 command?

rick jones

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
