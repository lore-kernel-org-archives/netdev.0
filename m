From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2 0/2] tc: flower: Support matching on SCTP ports
Date: Fri, 18 Nov 2016 14:27:27 +0100
Message-ID: <20161118132725.GA7111@penelope.isobedori.kobe.vergenet.net>
References: <1478176001-29174-1-git-send-email-simon.horman@netronome.com>
 <20161112103209.242d3e5e@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36739 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752247AbcKRN1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 08:27:40 -0500
Received: by mail-wm0-f50.google.com with SMTP id g23so38343784wme.1
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 05:27:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161112103209.242d3e5e@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 12, 2016 at 10:32:09AM +0300, Stephen Hemminger wrote:
> On Thu,  3 Nov 2016 13:26:39 +0100
> Simon Horman <simon.horman@netronome.com> wrote:
> 
> > Hi,
> > 
> > this short series adds support for matching on SCTP ports in the same way
> > that matching on TCP and UDP ports is already supported. It corresponds to
> > a net-next patch to add the same support to the kernel.
> > 
> > Example usage:
> > 
> > tc qdisc add dev eth0 ingress
> > 
> > tc filter add dev eth0 protocol ip parent ffff: \
> >     flower indev eth0 ip_proto sctp dst_port 80 \
> >     action drop
> > 
> > 
> > Simon Horman (2):
> >   tc: update headers for TCA_FLOWER_KEY_SCTP_*
> >   tc: flower: Support matching on SCTP ports
> > 
> >  include/linux/pkt_cls.h |  5 ++++
> >  tc/f_flower.c           | 65 +++++++++++++++++++++++--------------------------
> >  2 files changed, 36 insertions(+), 34 deletions(-)
> > 
> 
> Applied, thanks.

Hi Stephen,

I'm not seeing these on
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Could you push them or let me know where to look?
I found a few problems that want fixing.
