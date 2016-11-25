From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Fri, 25 Nov 2016 13:45:20 +1100
Message-ID: <20161125134520.68ca0969@canb.auug.org.au>
References: <20161125120947.142c3af5@canb.auug.org.au>
        <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eli Cooper <elicooper@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:41793 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751303AbcKYCpW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 21:45:22 -0500
In-Reply-To: <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eli,

On Fri, 25 Nov 2016 10:18:12 +0800 Eli Cooper <elicooper@gmx.com> wrote:
>
> Sounds like TSO/GSO packets are not properly segmented and therefore
> dropped.
> 
> Could you first try turning off segmentation offloading for the tunnel
> interface?
>     ethtool -K sit0 tso off gso off

On Thu, 24 Nov 2016 18:30:14 -0800 Eric Dumazet <eric.dumazet@gmail.com>
>
> You also could try to disable TSO and see if this makes a difference
> 
> ethtool -K sixtofour0 tso off

So turning off tso brings performance up to IPv4 levels ...

Thanks for that, it solves my immediate problem.
-- 
Cheers,
Stephen Rothwell
