From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Thu, 10 Apr 2014 21:20:29 -0700
Message-ID: <1397190029.16584.87.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <534753D4.6070600@linux-ipv6.org>
	 <1397186427.16584.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140410.233020.1295376284838706264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
	f.wellenreiter@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36743 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaDKEUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 00:20:30 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so4771947pdi.33
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 21:20:30 -0700 (PDT)
In-Reply-To: <20140410.233020.1295376284838706264.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-10 at 23:30 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 10 Apr 2014 20:20:27 -0700
> 
> > +/* We do not (yet ?) support IPv6 jumbograms (RFC 2675)
> > + * Unlike IPv4, hdr->seg_len doesn't include the IPv6 header
> > + */
> > +#define IP6_MAX_MTU (0xFFFF + sizeof(struct ipv6hdr))
> 
> Hmmm, does this still match $Subj?

Ugh, sorry, I had to run. I'll resend. 
