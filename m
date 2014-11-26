From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 3/5] net: Check for presence of IFLA_AF_SPEC
Date: Wed, 26 Nov 2014 05:30:57 -0800
Message-ID: <CAL3LdT5W=eMxdX36fMMYue9GdGrt9Gt0YHbVw+MWS2SDG2G3Pw@mail.gmail.com>
References: <cover.1417005245.git.tgraf@suug.ch>
	<495eced061d109e02b035ad56e56a3de2505ee22.1417005245.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:57630 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbaKZNa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 08:30:58 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so2137879obc.39
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 05:30:57 -0800 (PST)
In-Reply-To: <495eced061d109e02b035ad56e56a3de2505ee22.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 4:42 AM, Thomas Graf <tgraf@suug.ch> wrote:
> ndo_bridge_setlink() is currently only called on the slave if
> IFLA_AF_SPEC is set but this is a very fragile assumption and may
> change in the future.
>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c   | 2 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
>  2 files changed, 4 insertions(+)
>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
