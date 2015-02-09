From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [PATCH] net:ethernet:intel:Remove outdated fix me
 comment in the function, gb_acquire_swfw_sync_i210
Date: Mon, 9 Feb 2015 09:03:54 -0800 (PST)
Message-ID: <alpine.NEB.2.11.1502090901440.395@chris.i8u.org>
References: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>
	<1423444889.2589.165.camel@jtkirshe-mobl>
	<54D85EFA.3020501@gmail.com>
	<1423470722.27854.11.camel@jtkirshe-mobl>
	<87egpzqvpc.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bruce.w.allan@intel.com,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, Andrej Manduch <amanduch@gmail.com>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <87egpzqvpc.fsf@nemi.mork.no>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 9 Feb 2015, Bj?rn Mork wrote:

> Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
>
>> If you want to see Nick's patch, feel free to view his patch on
>> my queue tree:
>> https://git.kernel.org/cgit/linux/kernel/git/jkirsher/queue.git/
>
> which said:
>  - s32 i = 0, timeout = 200; /* FIXME: find real value to use here */
>  + s32 i = 0, timeout = 200;
>
>
> Comments like the one deleted by that patch do have some value in my
> opinion: They document that the constant is chosen arbitrarily and is
> not taken from some datasheet.
>
> Not a big deal, but leaving such comments, even if the value never ever
> changes, could save someone from trying to figure out where the heck you
> got that constant.  And there's noone actually misinterpreting this
> comment as "something needs to be fixed here", is there? So the cost of
> leaving the comment is exactly zero.
>
> Just my .02 ?.  I'm not going to tell you how to maintain your driver,
> of course.  At least I try not to :-)

I think, for now, we should NAK this. It's a short comment and you don't
want me to replace it with a philosophical statement on how you could
tune the timeout. That's what the data sheet is for.

(Replying from my home account and not my work account -
todd.fujinaka@intel.com)

------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
