From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: sctp: get rid of SCTP_DBG_TSNS entirely
Date: Mon, 1 Jul 2013 16:49:58 -0400
Message-ID: <20130701204958.GB3168@hmsreliant.think-freely.org>
References: <1372671096-27129-1-git-send-email-dborkman@redhat.com>
 <20130701113342.GA3168@hmsreliant.think-freely.org>
 <51D1AF75.50907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48817 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518Ab3GAUu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:50:29 -0400
Content-Disposition: inline
In-Reply-To: <51D1AF75.50907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 01, 2013 at 06:33:57PM +0200, Daniel Borkmann wrote:
> On 07/01/2013 01:33 PM, Neil Horman wrote:
> >On Mon, Jul 01, 2013 at 11:31:36AM +0200, Daniel Borkmann wrote:
> >>After having reworked the debugging framework, Neil and Vlad agreed to
> >>get rid of the leftover SCTP_DBG_TSNS code for a couple of reasons:
> >>
> >>We can use systemtap scripts to investigate these things, we now have
> >>pr_debug() helpers that make life easier, and if we really need anything
> >>else besides those tools, we will be forced to come up with something
> >>better than we have there. Therefore, get rid of this ifdef debugging
> >>code entirely for now.
> >>
> >>Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> >>CC: Vlad Yasevich <vyasevich@gmail.com>
> >>CC: Neil Horman <nhorman@tuxdriver.com>
> >>---
> >>  On top of [PATCH net-next v4 0/2] Rework SCTP debugging framework.
> >>
> >I think you mean on top of v4 2/2, but regardless:
> >
> >Acked-by: Neil Horman <nhorman@tuxdriver.com>
> >
> >I don't suppose you want to write a stap script to drop in the sourceware
> >examples area, in case anyone comes looking for this functionality again? :)
> 
> I could put this into my longer-term todo queue, sure, sounds like a plan.
> 
Sounds reasonable.  If I get time I'll let you know and take a poke at it
myself.

Thanks
Neil

> >Thanks
> >Neil
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
