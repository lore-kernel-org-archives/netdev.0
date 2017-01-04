From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH] Introduce a sysctl that modifies the value of PROT_SOCK.
Date: Wed, 4 Jan 2017 02:19:27 -0800
Message-ID: <20170104101927.GG3009@templeofstupid.com>
References: <20161231041111.GD2448@templeofstupid.com>
 <20161231125505.7f0c7dff@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:48129 "EHLO
        homiemail-a124.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965474AbdADKk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 05:40:28 -0500
Received: from homiemail-a124.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a124.g.dreamhost.com (Postfix) with ESMTP id B8C6260000D07
        for <netdev@vger.kernel.org>; Wed,  4 Jan 2017 02:40:27 -0800 (PST)
Received: from kmjvbox (c-73-70-90-212.hsd1.ca.comcast.net [73.70.90.212])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a124.g.dreamhost.com (Postfix) with ESMTPSA id A08BC60000D01
        for <netdev@vger.kernel.org>; Wed,  4 Jan 2017 02:40:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161231125505.7f0c7dff@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 31, 2016 at 12:55:05PM -0800, Stephen Hemminger wrote:
> On Fri, 30 Dec 2016 20:11:11 -0800
> Krister Johansen <kjlx@templeofstupid.com> wrote:
> 
> >  
> > +config LOWPORT_SYSCTL
> > +	bool "Adjust reserved port range via sysctl"
> > +	depends on SYSCTL
> > +	help
> > +	  This allows the administrator to adjust the reserved port range
> > +	  using a sysctl.
> 
> This looks like a good idea, and makes a lot of sense.
> 
> Please don't introduce yet another config option. All distro's will enable it anyway.
> Having more config options doesn't help reliability or testability.
> 
> Do or do not, please no new config options.

I'd be happy to take it out.  It simplifies things for me.  I had
anticipated that there would be objections to permitting software to get
around the current priviliged port restrictions, and thought that
perhaps as a compromise having it be compile time option would ease some
of those concerns.

-K
