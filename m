From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next 0/4] net: support MPLS in IPv4 and UDP
Date: Thu, 7 Jul 2016 07:38:16 +0200
Message-ID: <20160707053814.GB10002@penelope.isobedori.kobe.vergenet.net>
References: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
 <CALx6S36-zs0SEYgKz4koRhsAaadPaWh_w4SYczp_MwxALKqO5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36898 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756199AbcGGFiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:38:19 -0400
Received: by mail-wm0-f47.google.com with SMTP id a66so17686312wme.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 22:38:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36-zs0SEYgKz4koRhsAaadPaWh_w4SYczp_MwxALKqO5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2016 at 09:44:13PM -0700, Tom Herbert wrote:
> On Wed, Jul 6, 2016 at 11:22 AM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > This short series provides support for MPLS in IPv4 (RFC4023), and by
> > virtue of FOU, MPLS in UDP (RFC7510).
> >
> > The changes are as follows:
> > 1. Teach tunnel4.c about AF_MPLS, it already understands AF_INET and
> >    AF_INET6
> > 2. Enhance IPIP and SIT to handle MPLS. Both already handle IPv4.
> >    SIT also already handles IPv6.
> > 3. Trivially enhance MPLS to allow routes over SIT and IPIP tunnels.
> >
> 
> HI Siomon,
> 
> Thanks for these patches! Can provide the commands for testing this?

Sure, will do.
