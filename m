From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [RFC PATCH 1/5] net: implement support for low
 latency socket polling
Date: Tue, 05 Mar 2013 12:03:02 -0800
Message-ID: <51364F76.4060107@zytor.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	<20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
	<1362501781.2791.19.camel@bwh-desktop.uk.solarflarecom.com>
	<20130305.145524.1486936679665458305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eliezer.tamir@linux.jf.intel.com, willemb@google.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	andi@firstfloor.org, bhutchings@solarflare.com, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130305.145524.1486936679665458305.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 03/05/2013 11:55 AM, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 5 Mar 2013 16:43:01 +0000
> 
>> In general it appears to require a run-time check.  You might need to
>> augment <asm/timex.h>.
> 
> On the other hand, unlike get_cycles, sched_clock() is always available.
> 

On the gripping hand, we need to know when it uses something like
jiffies, in which case we probably need to disable the whole interface.

	-hpa


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
