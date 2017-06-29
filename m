From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v2 3/9] nfp: provide infrastructure for
 offloading flower based TC filters
Date: Wed, 28 Jun 2017 18:53:40 -0700
Message-ID: <20170628185340.1ea53cd1@cakuba.netronome.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
        <1498681802-2897-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36307 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751580AbdF2Bxn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 21:53:43 -0400
Received: by mail-pg0-f54.google.com with SMTP id u62so40080149pgb.3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 18:53:43 -0700 (PDT)
In-Reply-To: <1498681802-2897-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jun 2017 22:29:56 +0200, Simon Horman wrote:
> +/**
> + * nfp_flower_del_offload() - Removes a flow from hardware.
> + * @app:	Pointer to the APP handle
> + * @netdev:	netdev structure.
> + * @flow: =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TC flower classifier offlo=
ad structure

Nit: there are spaces and tabs mixed here, same for
nfp_flower_get_stats().

> + *
> + * Removes a flow from the repeated hash=C2=A0structure and clears the
> + * action payload.
> + *
> + * Return: negative value on error, 0 if removed successfully.
> + */
> +static int
> +nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
> +		       struct tc_cls_flower_offload *flow)
> +{
> +	return -EOPNOTSUPP;
> +}
