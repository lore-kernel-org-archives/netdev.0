From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 1/1] myri10ge: use physical pages for skb allocation
Date: Wed, 15 Nov 2006 23:40:11 +0100
Message-ID: <455B974B.9070302@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:56992 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1162023AbWKOWli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 17:41:38 -0500
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

It looks like you didn't apply this patch to #upstream for 2.6.20 so far. We would really like to get ith in 2.6.20 (we already missed 2.6.19 by a couple days :)). But, I guess we need some testing in -mm first, so...

thanks,
Brice





Brice Goglin wrote:
> Physical pages are used instead of 16kB contiguous buffers for the
> skb frags. And we also put as much fragments as possible in any page
> so that we do not have to allocate a page for every fragments.
>
> Signed-off-by: Brice Goglin <brice@myri.com>
> Signed-off-by: Andrew J. Gallatin <gallatin@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |  499 ++++++++++++++++++++--------------------
>  1 file changed, 254 insertions(+), 245 deletions(-)
>   

