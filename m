From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 14:49:37 -0800
Message-ID: <20091113144937.23693bb4@nehalam>
References: <200911130701.14847.opurdila@ixiacom.com>
	<4AFCF8D3.6090905@gmail.com>
	<20091112222608.79d90e9e@nehalam>
	<200911131151.31677.opurdila@ixiacom.com>
	<20091113142939.35879efe@s6510>
	<20091113224043.GP19478@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55696 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932224AbZKMWt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 17:49:58 -0500
In-Reply-To: <20091113224043.GP19478@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 17:40:43 -0500
Benjamin LaHaise <bcrl@lhnet.ca> wrote:

> On Fri, Nov 13, 2009 at 02:29:39PM -0800, Stephen Hemminger wrote:
> > So it is lots of pseudo-devices for a special purpose test machine.
> > That's great use of Linux, but not a case worth optimizing for in the mainline kernel.
> 
> He's not the only one who needs that, I certainly do.  BRAS application 
> where traffic is being aggregated (ie PPPoE and L2TP servers) from lots of 
> customers requires it.  There are also people hitting the same scaling 
> issues in embedded PPPoE on wireless networks.
> 
> 		-ben

Then maybe network devices aren't the right layering model. At some
point the paradigm has to be re-examined.

-- 
