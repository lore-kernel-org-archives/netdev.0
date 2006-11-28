From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/2] chelsio: T200 support
Date: Tue, 28 Nov 2006 12:27:26 -0800
Message-ID: <20061128122726.756fb6ed@dxpl.pdx.osdl.net>
References: <8A71B368A89016469F72CD08050AD334DA4F5C@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <akpm@osdl.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:2185 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1756296AbWK1U23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 15:28:29 -0500
To: "Felix Marti" <felix@chelsio.com>
In-Reply-To: <8A71B368A89016469F72CD08050AD334DA4F5C@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Nov 2006 10:03:31 -0800
"Felix Marti" <felix@chelsio.com> wrote:

> Andrew:
> > On Tue, 28 Nov 2006 00:17:38 +0100
> > Francois Romieu <romieu@fr.zoreil.com> wrote:
> >
> > > Stephen Hemminger <shemminger@osdl.org> :
> > > > This patch is experimental, it applies after the earlier 6 chelsio
> cleanup
> > > > patches. Tested on a pair of T210 board's.
> > > 
> > > The whole serie is stored as branch 'chelsio' at:
> > >
> git://electric-eye.fr.zoreil.com/home/romieu/linux/linux-2.6-out/.git
> chelsio
> >
> > I think you meant
> > git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git#chelsio
> >
> > > I have hand-edited a few patches to convert some spaces/tabs.
> >
> > I'll try adding this to -mm.
> >
> > I hope someone knows what's happening with this driver, because I've
> > seriously lost the plot.
> 
> Most customers have been downloading the T2xx driver from our website in
> order to take advantage of the TOE capability of the T2xx hardware.
> However, there is value in updating the in-kernel driver (which supports
> N110 and N210 only) to support the T2xx products in NIC mode. I will
> test the patches this week and get back to the mailing list if there are
> any issues.
> 

I am seeing lots of little bugs (like not using free_netdev), that would
have been caught if the current driver was in mainline.
