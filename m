From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: TAP (and TUN?) devices not working after resume
Date: Thu, 24 Jul 2008 20:50:32 -0700
Message-ID: <48894D88.9010104@qualcomm.com>
References: <20080714154720.791f6640@symphony> <200807141812.45264.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: suspend-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <suspend-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200807141812.45264.rjw@sisk.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/suspend-devel>,
	<mailto:suspend-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=suspend-devel>
List-Post: <mailto:suspend-devel@lists.sourceforge.net>
List-Help: <mailto:suspend-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/suspend-devel>,
	<mailto:suspend-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: suspend-devel-bounces@lists.sourceforge.net
Errors-To: suspend-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



Rafael J. Wysocki wrote:
> On Monday, 14 of July 2008, James Le Cuirot wrote:
>> Hi,
> 
> Hi,
> 
>> uswsusp works great on my machine except for one thing. I use a TAP
>> device for QEMU and after resuming from suspend, it doesn't work
>> anymore until I delete it and recreate it. This is rather annoying
>> because if I have QEMU open, it means I have to close it before
>> recreating the interface and then boot Windows up again. I use OpenVPN
>> to create/delete the interface but I think that's all it does. The rest
>> is done by the kernel. So I'm guessing something's up with the TUN/TAP
>> driver or uswsusp itself. I'm using version 0.8. Sorry if this has
>> already been fixed.
> 
> This is a kernel problem, adding kernel-related CCs.

I bet it's flow control related. I've fixed a bug in flow control handling for
persistent devices recently.
btw Does it still happen with >= 2.6.26 ?

I'll play with some test code on my laptop and see if I can reproduce this issue.

Max

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
