From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: Enable accelerated RFS on vlans
Date: Thu, 16 May 2013 21:00:47 +0100
Message-ID: <1368734447.2655.32.camel@bwh-desktop.uk.solarflarecom.com>
References: <4bdabd4670b726348cdcdc0d2d635dd660671ee3.1368229353.git.luto@amacapital.net>
	 <1368729524.2655.30.camel@bwh-desktop.uk.solarflarecom.com>
	 <CALCETrVpEz_WdG9bKjUSR3OKyERd+hMLwK8+_84L5WxepQrS1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53999 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410Ab3EPUAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 16:00:51 -0400
In-Reply-To: <CALCETrVpEz_WdG9bKjUSR3OKyERd+hMLwK8+_84L5WxepQrS1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 12:45 -0700, Andy Lutomirski wrote:
> On Thu, May 16, 2013 at 11:38 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Fri, 2013-05-10 at 16:51 -0700, Andy Lutomirski wrote:
> >> As far as I know, the hardware doesn't support matching on both IP
> >> fields and vlan tag, but it can at least match on the vlan tag.
> >>
> >> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> >> ---
> >>
> >> Tested on the OpenOnload version of the driver, but the patch is the same
> >> other than some offset.
> >
> > This looks correct, but I'll have to actually test it.  So I'll queue
> > this up and re-submit along with other sfc patches later on, OK?
> 
> Fine with me.  (Is there a combined vlan + IP filter that I don't know about?)

Not in current hardware.

> When you resubmit it, it might be worth fixing the blatant typo (vlan
> tag -> IP fields) in the description, though :/
[...]

Good point!

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
