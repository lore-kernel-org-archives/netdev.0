From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 3/7] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Thu, 27 Mar 2008 22:42:20 -0300
Message-ID: <20080328014220.GK14945@ghostprotocols.net>
References: <1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi> <1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi> <200803280036.59311.vda.linux@googlemail.com> <20080327.175212.119805454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vda.linux@googlemail.com, ilpo.jarvinen@helsinki.fi,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54974 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682AbYC1Bmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 21:42:33 -0400
Content-Disposition: inline
In-Reply-To: <20080327.175212.119805454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Mar 27, 2008 at 05:52:12PM -0700, David Miller escreveu:
> From: Denys Vlasenko <vda.linux@googlemail.com>
> Date: Fri, 28 Mar 2008 00:36:59 +0100
> 
> > Can you add a comment which explains the intent?
> > 
> > +struct sk_buff *dev_alloc_skb(unsigned int length)
> > +{
> > +       /* There is more code here than it seems:
> > +        * __dev_alloc_skb is an inline */
> > +	return __dev_alloc_skb(length, GFP_ATOMIC);
> > +}
> > +EXPORT_SYMBOL(dev_alloc_skb);
> 
> I've applied his patch already, if you want this comment
> please submit the patch to add it and also please use
> the correct formatting of the comment.

Which is, of course:

	/*
	 * There is more code here than it seems:
	 * __def_alloc_skb is an inline
	 */

Ilpo: Keep up the debloating jihad/crusade/campaign/surge/kamppailla! 8-)

- arnaldo
