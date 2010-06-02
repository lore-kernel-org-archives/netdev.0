From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 00/12] sfc changes for 2.6.36
Date: Wed, 02 Jun 2010 16:04:34 +0100
Message-ID: <1275491074.2115.1.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
	 <20100602.022144.63047920.davem@davemloft.net>
	 <1275486746.2870.31.camel@localhost>
	 <20100602.065711.191161830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38539 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755646Ab0FBPEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 11:04:38 -0400
In-Reply-To: <20100602.065711.191161830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 06:57 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 02 Jun 2010 14:52:26 +0100
> 
> > Did you apply patch 12 "sfc: Get port number from CS_PORT_NUM, not PCI
> > function number" to net-2.6?
> 
> When you mix bug fixes and cleanups, I'm going to apply it all to
> net-next-2.6 You didn't even specify an intended destination in your
> subject lines, so you leave it entirely open for interpretation and
> my choice.
> 
> So, if you want a bug fix added to net-2.6, tossing it into a series
> which is not wholly appropriate for net-next-2.6 is not that way to
> accomplish that.

Well, I included a comment in the message and left it to your judgement
as to whether it was more appropriate for net-next-2.6 or net-2.6.

> The way to do it is:
> 
> 1) Submit the bug fix, explicitly state "[PATCH net-2.6 xxx] "
>    in your subject line.
> 
> 2) Prepare your net-next-2.6 changes on top of that, and do one
>    of two things:
>    a) Explicitly state in your patch series in the "[PATCH net-next-2.6 0/xxx] "
>       posting "this depends upon the bug fixes posted in the series
>       XXX posted earlier.
>    b) Wait for the bug fix to reach net-next-2.6 when I do a merge,
>       then post your series.

There are no dependencies in this case.

> Otherwise you make life way to miserable and complicated for me,
> the one who has to review and integrate all of your work.

Sorry.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

