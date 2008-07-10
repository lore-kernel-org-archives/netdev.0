From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] sctp: remove unnecessary byteshifting, calculate crc
	in	big-endian
Date: Wed, 09 Jul 2008 18:01:44 -0700
Message-ID: <1215651704.476.92.camel@brick>
References: <1215133995.16647.51.camel@brick>  <487526B8.70903@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:60189 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbYGJD2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 23:28:50 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1943995waf.23
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2008 20:28:50 -0700 (PDT)
In-Reply-To: <487526B8.70903@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-09 at 16:59 -0400, Vlad Yasevich wrote:
> Harvey Harrison wrote:
> > -	__u32 crc32 = 0;
> > +	__be32 crc32 = cpu_to_be32(0);
> 
> Does this actually do anything?
> 
> Otherwise, good clean-up. Thanks
> 

Keeps sparse happy.

Harvey

