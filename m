From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 03/16] i40evf: Support RSS option in ethtool
Date: Mon, 17 Mar 2014 16:40:20 +0200
Message-ID: <CAJZOPZJWCDGcC3hWAVsLkN8LSY-7GifDSKN6OhDRjgwFpjtuSw@mail.gmail.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395060316-16897-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42066 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933197AbaCQOkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 10:40:21 -0400
Received: by mail-pa0-f46.google.com with SMTP id kp14so5744459pab.5
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 07:40:20 -0700 (PDT)
In-Reply-To: <1395060316-16897-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 2:45 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
>
> Add support for viewing and modifying RSS hash options and RSS hash
> look-up table programming through ethtool.
[...]

FWIW, this commit does more... wouldn't it be worth dropping some
words on that on that change-log?

[...]
>  static struct ethtool_ops i40evf_ethtool_ops = {
>         .get_settings           = i40evf_get_settings,
>         .get_drvinfo            = i40evf_get_drvinfo,
> @@ -378,6 +687,12 @@ static struct ethtool_ops i40evf_ethtool_ops = {
>         .set_msglevel           = i40evf_set_msglevel,
>         .get_coalesce           = i40evf_get_coalesce,
>         .set_coalesce           = i40evf_set_coalesce,
> +       .get_rxnfc              = i40evf_get_rxnfc,
> +       .set_rxnfc              = i40evf_set_rxnfc,
> +       .get_rxfh_indir_size    = i40evf_get_rxfh_indir_size,
> +       .get_rxfh_indir         = i40evf_get_rxfh_indir,
> +       .set_rxfh_indir         = i40evf_set_rxfh_indir,
> +       .get_channels           = i40evf_get_channels,
>  };
