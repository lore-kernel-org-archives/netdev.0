From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] sctp: remove unnecessary byteshifting, calculate crc
	in	big-endian
Date: Thu, 17 Jul 2008 12:21:01 -0700
Message-ID: <1216322461.6029.3.camel@brick>
References: <1215133995.16647.51.camel@brick>  <487526B8.70903@hp.com>
	 <1215651704.476.92.camel@brick>  <487603F0.9070604@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:59781 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759316AbYGQTVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 15:21:03 -0400
Received: by wf-out-1314.google.com with SMTP id 27so55450wfd.4
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 12:21:03 -0700 (PDT)
In-Reply-To: <487603F0.9070604@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-07-10 at 08:43 -0400, Vlad Yasevich wrote:
> Harvey Harrison wrote:
> > On Wed, 2008-07-09 at 16:59 -0400, Vlad Yasevich wrote:
> >> Harvey Harrison wrote:
> >>> -	__u32 crc32 = 0;
> >>> +	__be32 crc32 = cpu_to_be32(0);
> >> Does this actually do anything?
> >>
> >> Otherwise, good clean-up. Thanks
> >>
> > 
> > Keeps sparse happy.
> 
> Wouldn't just a (__force __be32)0 do the same thing and
> avoid useless byte swapping on little endian?
> 

Vlad, do you want me to revise the patch, or were you taking it as is?

Harvey

