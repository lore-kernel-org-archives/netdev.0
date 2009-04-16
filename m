From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 13:44:22 -0400
Message-ID: <20090416174422.GB28978@hmsreliant.think-freely.org>
References: <alpine.DEB.1.10.0904161035390.19650@qirst.com> <20090416151504.GA28978@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904161136220.15629@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, dlstevens@us.ibm.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36179 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755875AbZDPRoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 13:44:32 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904161136220.15629@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 11:36:56AM -0400, Christoph Lameter wrote:
> On Thu, 16 Apr 2009, Neil Horman wrote:
> 
> > I think your comment is reveresed here isn't it?  the default you have below is
> > that mc_all is set, which defaults you to the existing behavior, rather than the
> > new behavior introduced by this patch.
> 
> mc_all is 0 by default.
> 
> > Ack to the patch though
> > Acked-by: Neil Horman <nhorman@tuxdriver.com>
> > Neil
> 
> Thanks.
> 
I'm sorry, I misread it (confused the definiton of a bitfield with its default
value.  As Dave noted, the default needs to be the current behavior, not your
new behavior.  Until thats changed, I rescind my Ack
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
