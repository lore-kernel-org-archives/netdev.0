From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN regression caused by: e1000: do vlan cleanup
	(799d531).
Date: Tue, 13 Mar 2012 09:18:23 -0700
Message-ID: <4F5F734F.5050301@candelatech.com>
References: <4F5E3DCF.6010307@candelatech.com>
	<20120313095942.GC2239@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120313095942.GC2239@minipsycho.brq.redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 03/13/2012 02:59 AM, Jiri Pirko wrote:
> Mon, Mar 12, 2012 at 07:17:51PM CET, greearb@candelatech.com wrote:

>> Please let me know if you need additional info.  I'll be happy to test patches,
>> I have a good setup to reproduce this easily.
>
> Thanks for the report Ben.
>
> It would help it you try to enable/disable vlan hw accel by ethtool to
> see if it helps.
>
> I have suspition that vlan filter must be on/offed along with vlan
> accel.

Can that even be done in the 3.0 kernel?  Or do you want me to just
try the 3.3-rxX kernel?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
