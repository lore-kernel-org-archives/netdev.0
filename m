From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2/net-next 7/7] tc: flower: Support matching on ND
Date: Mon, 6 Feb 2017 09:44:00 +0100
Message-ID: <20170206084359.GA20384@penelope.horms.nl>
References: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
 <1486031920-10784-8-git-send-email-simon.horman@netronome.com>
 <20170202172748.GE1845@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38544 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdBFIoE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 03:44:04 -0500
Received: by mail-wm0-f49.google.com with SMTP id r141so103937887wmg.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 00:44:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170202172748.GE1845@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 06:27:48PM +0100, Jiri Pirko wrote:
> Thu, Feb 02, 2017 at 11:38:40AM CET, simon.horman@netronome.com wrote:
> >Allow matching on Neighbour Discovery target IP, and source and
> >destination link-layer addresses for neighbour solicitation and
> >advertisement messages.
> >
> >Sample usage:
> >
> >tc qdisc add dev eth0 ingress
> >
> >tc filter add dev eth0 protocol ipv6 parent ffff: flower \
> >	indev eth0 ip_proto icmpv6 type 136 code 0 \
> >	nd_target 2001:470:7eb3:403:201:8eff:fe22:8fea \
> >	nd_tll 00:01:8e:22:8f:ea action drop
> >
> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> 
> Why you are adding this to iproute2? You only poster RFC for kernel.
> 
> Please push to kernel first, let it merge, then send iproute2 support.

Hi Jiri,

I think there is a value in making the user-space code available in
parallel with the kernel changes to allow testing and so by any interested
parties.

If this is not acceptable I'm happy to stop doing so. But in my ideal world
I'd be very happy to see other TC kernel updates accompanied by
implementations their user-space tool counterparts.
