From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next v4 3/9] static_key: WARN on usage before
 jump_label_init was called
Date: Wed, 6 Nov 2013 20:02:00 -0500
Message-ID: <20131106200200.7847535d@gandalf.local.home>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
	<1382212139-20301-4-git-send-email-hannes@stressinduktion.org>
	<20131106161649.2bb1dbb0@gandalf.local.home>
	<20131107005027.GC8144@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andi Kleen <andi@firstfloor.org>,
	Ingo Molnar <mingo@kernel.org>, Jason Baron <jbaron@akamai.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:14470 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751016Ab3KGBC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:02:26 -0500
In-Reply-To: <20131107005027.GC8144@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Nov 2013 01:50:27 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Wed, Nov 06, 2013 at 04:16:49PM -0500, Steven Rostedt wrote:
> > Sorry for the late reply, but this was sent while I was getting ready
> > for my two week conference trip.
> > 
> > Note, this should not go through the net tree, but instead should go
> > through tip, as it deals with jump labels and not networking.
> > 
> > Otherwise, this patch looks good.
> > 
> > Reviewed-by: Steven Rostedt <rostedt@goodmis.org>
> 
> Thanks for the review!
> 
> The patch already got queued up in net-next. Is this ok or what do you
> suggest to resolve this?
> 

I'm fine, but really. Changes need to go through the trees they are
maintained by. Would Dave Miller like it if I pushed patches that
touched the net directory without a single Ack?

-- Steve
