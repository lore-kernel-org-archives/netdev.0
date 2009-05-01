From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: add mark mode
Date: Fri, 1 May 2009 16:39:00 -0400
Message-ID: <20090501203900.GC5840@hmsreliant.think-freely.org>
References: <20090501173916.GA6608@gospo.rdu.redhat.com> <20090501193403.GA5840@hmsreliant.think-freely.org> <501.1241207536@death.nxdomain.ibm.com> <20090501200940.GB5840@hmsreliant.think-freely.org> <5384.1241209883@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37033 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763465AbZEAUjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 16:39:21 -0400
Content-Disposition: inline
In-Reply-To: <5384.1241209883@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 01, 2009 at 01:31:23PM -0700, Jay Vosburgh wrote:
> Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> >> 	If I'm not misunderstanding the purpose of the mode, I think
> >> it's etherchannel compatible (meaning that the switch has to be
> >> configured), so I'm not sure why there would ever be a need to flood
> >> packets to all ports.
> >> 
> >It entirely possible that there may be no need to flood frames, I was just
> >asking the question.  And while it is possible that this might be etherchannel
> >compatible (in fact I agree, it does look compatible), I can see uses for it
> >beyond that (active-backup with traffic-class load balancing for example).
> 
> 	For that last comment (active-backup), are you thinking in terms
> of N active slaves and one backup?
> 
I suppose.  I really didn't have anything specific in mind, I was just musing on
what potential this might have.  As Andy mentioned in his post, this could be
used as an active backup mode where the backup links can still carry traffic.

> >> 	I think this would be generally be better a special hash policy,
> >> in which case both the etherchannel (balance-xor) and 802.3ad modes
> >> could take advantage of it.  I'd hazard to guess that Andy thought about
> >> that, too, so what was the impediment?
> >
> >I honestly don't know, although I will say that making a special hash mode for
> >balance-xor seems a bit odd, since the implication there would be that output
> >port was no longer chosen by an xor operation.
> 
> 	Well, there are already three different hash algorithms that can
> be selected, and if the only thing stopping this functionality as some
> type of different slave selection gizmo is terminology, then I'm happy
> to change the name of "xmit_hash_policy" to simply "xmit_policy" (in a
> backwards compatible manner, of course) and slap this in as a new
> policy.  Yah, balance-xor has "xor" in the name, but that can either be
> documented around or, again, aliased as "balance-policy" or something.
> 
> 	I see no reason the terminology should stand in the way of
> setting things up The Right Way (which, in this discussion, revolves
> around this type of new slave selection stuff working for the largest
> reasonable set of modes, here, etherchannel and 802.3ad).
> 
I'll stay out of your way and let you and Andy hash out "The Right Way" :).  I
just like the idea of being able to select your output destination :)

Neil

