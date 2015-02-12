From: Chris Vine <chris@cvine.freeserve.co.uk>
Subject: Re: xt_recent broken in kernel 3.19.0 + PATCH
Date: Thu, 12 Feb 2015 11:11:15 +0000
Message-ID: <20150212111115.63d5ee43@bother.homenet>
References: <20150211092834.65f8ae80@bother.homenet>
	<20150211183121.6688aec8@bother.homenet>
	<CAM_iQpVmxw_XfzP7yaPWbhu8UBujebm1vjumgPPH1TUdHgs0rA@mail.gmail.com>
	<20150212083533.GC22887@breakpoint.cc>
	<20150212102616.786da70c@bother.homenet>
	<20150212105417.0379fed8@bother.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150212105417.0379fed8@bother.homenet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Feb 2015 10:54:17 +0000
Chris Vine <chris@cvine.freeserve.co.uk> wrote:
[snip]
> On further testing I see that that patch only solves the problem if
> SSH_TRIES is set to a power of two boundary.  You still get an error
> loading the rule if it is anything else.  I think there is something
> wrong with the nstamp_mask heuristic which is used here.

I now find that that is not right either.  I had to rmmod xt_recent to
get it to drop its previous setting.  With that done, the patch does
indeed seem to work for all values of SSH_TRIES.

Chris
