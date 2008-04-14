From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/5] e1000e: Add interrupt moderation
 run-time ethtool interface
Date: Mon, 14 Apr 2008 12:31:45 -0700
Message-ID: <4803B121.2060501@hp.com>
References: <20080414170557.23286.71580.stgit@localhost.localdomain>	<20080414170604.23286.86187.stgit@localhost.localdomain>
	<873apoutnt.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>, jeff@garzik.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <873apoutnt.fsf@basil.nowhere.org>
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

Andi Kleen wrote:
> Auke Kok <auke-jan.h.kok@intel.com> writes:
> 
> 
>>The ethtool -c / -C interface can now be used to modify the
>>irq moderation algorithm. This change does not require an
>>adapter reset and can thus be used at all times. The adapter
>>only supports changing/reading rx-usecs which has special
>>values for 0, 1 and 3:
>>
>>0 - no irq moderation whatsoever
>>1 - normal moderation favoring regular mixed traffic (default)
>>3 - best attempt at low latency possible at cost of CPU
> 
> 
> It would be nice if ethtool instead of having this as a obscure magic
> number had a higher level "--low-latency" or similar parameter
> (that could also potentially set similar settings on other NICs)
> 
> You think there would be a clean way to implement this? 

The biggest problems might be ones of interpretation as to whether a 
given setting was indeed:

--favor-latency
--favor-throutput
--favor-mixed

But it would indeed at one level be more "clear" to a random admin (IMO).

I use "--favor-mumble" above since what might be the --low-latency 
through one NIC might not be as low as the "--low-latency" though 
another NIC, and it also sort of implicitly suggests a trade-off is 
being made.

rick jones

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
