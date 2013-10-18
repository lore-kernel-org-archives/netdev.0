From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 3/9] static_key: WARN on usage before jump_label_init was called
Date: Fri, 18 Oct 2013 03:16:55 +0200
Message-ID: <20131018011655.GG18135@order.stressinduktion.org>
References: <1381987923-1524-1-git-send-email-hannes@stressinduktion.org> <1381987923-1524-4-git-send-email-hannes@stressinduktion.org> <20131017171940.173bab09@gandalf.local.home> <20131018005057.GL2592@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131018005057.GL2592@two.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 18, 2013 at 02:50:57AM +0200, Andi Kleen wrote:
> On Thu, Oct 17, 2013 at 05:19:40PM -0400, Steven Rostedt wrote:
> > On Thu, 17 Oct 2013 07:31:57 +0200
> > Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > 
> > > Based on a patch from Andi Kleen.
> > 
> > I'm fine with the patch, but the change log needs a lot more work.
> > Like, why is this needed?  I know, but does anyone else?
> 
> Or just merge the orininal patch. While being less verbose
> in the warning it had a full changelog.

I don't care that much which patch gets merged but I just want to
point out another difference: I added WARN_ONs on code paths without
architecture support for static_keys to help developers on platforms
without support for that.

Greetings,

  Hannes
