From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: Re: [patch 08/10] 802.3ad: remove public lacpdu_header
Date: Mon, 29 Dec 2008 17:15:41 +0100
Message-ID: <20081229161541.GA19173@mail.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org> <20081223220600.479443201@jonathan.eitzenberger.org> <20081226.134349.56490565.davem@davemloft.net> <20081226.134537.212403770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout-bounce.kundenserver.de ([212.227.17.2]:62795 "EHLO
	mout-bounce.kundenserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960AbYL2QPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 11:15:46 -0500
Content-Disposition: inline
In-Reply-To: <20081226.134537.212403770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 26, 2008 at 01:45:37PM -0800, David Miller wrote:

> > > -	skb = dev_alloc_skb(length);
> > > -	if (!skb) {
> > > +	skb = dev_alloc_skb(len);
> > > +	if (skb == NULL)
> > 
> > "!skb" is preferred to the long-winded "skb == NULL", so
> > I'm tossing this patch and the rest which touch similar
> > areas.
> 
> Also, I want to mention that your C++ comment conversions are not in
> the proper coding style as well.  You are doing:

As I'm currently offline most of the time I'll resend once I'm back
home.

Thanks for your feedback!

 /holger

