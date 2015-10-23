From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 10/11] net: ipv4: hlen could be set as size_t
Date: Fri, 23 Oct 2015 15:21:00 +0200
Message-ID: <20151023132100.GA16922@Red>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
 <1445602236-24130-11-git-send-email-clabbe.montjoie@gmail.com>
 <20151023.060852.167547226456492975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33163 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbbJWNVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:21:04 -0400
Content-Disposition: inline
In-Reply-To: <20151023.060852.167547226456492975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 06:08:52AM -0700, David Miller wrote:
> From: LABBE Corentin <clabbe.montjoie@gmail.com>
> Date: Fri, 23 Oct 2015 14:10:35 +0200
> 
> > The hlen member of raw_frag_vec is used in operation/function that wait
> > for unsigned value. So it need to be set as size_t.
> > 
> > Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
> 
> You really need to test your changes.
> 
> Particularly on a platform where size_t has a different size than
> 'int'.  That will generate several warnings, as shown by all of the
> build warning reports sent by the kbuild test robot in response to
> this patch series.
> 
> Also, you need to CC: all relevant mailing lists for the entire series
> of patches, and also provide a "Subject: [PATCH 0/N] xxx" posting
> describing at a high level and in detail what this patch series is
> doing, and why.
> 
> It should also clearly state what exact tree you expect these patches
> to be merged into.
> 
> Thanks.

Hello

I am sorry, I have badly checked my build logs.

I have added all mailing list given by get_maintainer but this was done per patch with --to-cmd/--cc-cmd
Does it is better to put all mailing list globally ?

For the (0/N) mail, I forgot to add a subject on it https://lkml.org/lkml/2015/10/23/219

I will fix all minor finding and resend a proper version.

Thanks

LABBE Corentin
