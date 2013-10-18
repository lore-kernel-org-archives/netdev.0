From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 3/9] static_key: WARN on usage before jump_label_init was called
Date: Fri, 18 Oct 2013 02:01:18 +0200
Message-ID: <20131018000118.GF18135@order.stressinduktion.org>
References: <1381987923-1524-1-git-send-email-hannes@stressinduktion.org> <1381987923-1524-4-git-send-email-hannes@stressinduktion.org> <20131017171940.173bab09@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andi Kleen <andi@firstfloor.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131017171940.173bab09@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 17, 2013 at 05:19:40PM -0400, Steven Rostedt wrote:
> On Thu, 17 Oct 2013 07:31:57 +0200
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> > Based on a patch from Andi Kleen.
> 
> I'm fine with the patch, but the change log needs a lot more work.
> Like, why is this needed?  I know, but does anyone else?

Ok. :)

I'll move the description from the changelog here and write something
in a few days (hope to get more feedback on the other parts, especially
net_get_random_once).

Does that also mean you are in principle ok with the patch weakening
the check in arch/x86/jump_label.c?

Thanks for the review,

  Hannes
