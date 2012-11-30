From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] ipv6: unify logic evaluating inet6_dev's accept_ra
 property
Date: Fri, 30 Nov 2012 21:51:13 +0200
Message-ID: <20121130215113.7a81bc16.shmulik.ladkani@gmail.com>
References: <1354181179-16294-1-git-send-email-shmulik.ladkani@gmail.com>
	<20121130.120943.1397811156693287841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, tgraf@suug.ch,
	tore@fud.no
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:46816 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932197Ab2K3Tvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 14:51:44 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so341217eaa.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 11:51:43 -0800 (PST)
In-Reply-To: <20121130.120943.1397811156693287841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 30 Nov 2012 12:09:43 -0500 (EST) David Miller <davem@davemloft.net> wrote:
> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Date: Thu, 29 Nov 2012 11:26:19 +0200
> 
> > +	/*
> > +	 * If forwarding is enabled, RA are not accepted unless the special
> > +	 * hybrid mode (accept_ra=2) is enabled.
> > +	 */
> 
> Please format this comment correctly, in the networking we use
> the style:
> 
> 	/* That looks
> 	 * like this.
> 	 */
> 
> 	/*
> 	 * Not
> 	 * like this.
> 	 */
> 
> Thanks.

Ok. Will amend shortly.

BTW the "Not like this" style has many occurrences in net/ipv6.
One of which was the comment relocated by my patch :-)

Regards,
Shmulik
