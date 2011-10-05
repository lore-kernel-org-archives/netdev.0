From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 5/7] bridge: allow creating/deleting fdb entries via
 netlink
Date: Wed, 05 Oct 2011 20:36:15 +0100
Message-ID: <1317843375.2802.29.camel@bwh-desktop>
References: <20110405000326.714524584@vyatta.com>
	 <20110405000537.372602366@vyatta.com>
	 <CAGXs5wXc0RLE9KbTVVYRa0xuLEKh8mTM7AR7hMBe86HNfDX0HQ@mail.gmail.com>
	 <20111005121305.26ac48bf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kevin Wilson <wkevils@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:56958 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933233Ab1JETgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 15:36:19 -0400
In-Reply-To: <20111005121305.26ac48bf@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-05 at 12:13 -0700, Stephen Hemminger wrote:
> On Wed, 5 Oct 2011 21:06:54 +0200
> Kevin Wilson <wkevils@gmail.com> wrote:
> 
> > Hello all,
> > I would appreciate if someone can elaborate about "bridge extensions
> > to iproute2" mentioned here.
> > I downloaded latest iproute2 git tree and did not find it there.
> > googling for it did not gave much info about it.
> > I will appreciate if someone can tell  who develop it, what is the
> > status, site, repository tree, etc.
> > 
> > rgs,
> > Kevin
> 
> The patch to handle this was posted, but is not committed to the tree yet.
[...]
> +static void usage(void)
> +{
> +	fprintf(stderr,
> +"Usage: br [ OPTIONS ] OBJECT { COMMAND | help }\n"
[...]

This and the sub-command usage functions still report the command name
as 'br'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
