From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 3/9] nfp: provide infrastructure for
 offloading flower based TC filters
Date: Thu, 29 Jun 2017 10:16:54 +0200
Message-ID: <20170629081652.GE29453@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-4-git-send-email-simon.horman@netronome.com>
 <20170628185340.1ea53cd1@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36982 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751855AbdF2IQ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 04:16:58 -0400
Received: by mail-wm0-f46.google.com with SMTP id i127so5786010wma.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 01:16:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170628185340.1ea53cd1@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 06:53:40PM -0700, Jakub Kicinski wrote:
> On Wed, 28 Jun 2017 22:29:56 +0200, Simon Horman wrote:
> > +/**
> > + * nfp_flower_del_offload() - Removes a flow from hardware.
> > + * @app:	Pointer to the APP handle
> > + * @netdev:	netdev structure.
> > + * @flow:       TC flower classifier offload structure
> 
> Nit: there are spaces and tabs mixed here, same for
> nfp_flower_get_stats().

Thanks for noticing that, we'll fix it.

> > + *
> > + * Removes a flow from the repeated hash structure and clears the
> > + * action payload.
> > + *
> > + * Return: negative value on error, 0 if removed successfully.
> > + */
> > +static int
> > +nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
> > +		       struct tc_cls_flower_offload *flow)
> > +{
> > +	return -EOPNOTSUPP;
> > +}
> 
