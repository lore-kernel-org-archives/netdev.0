From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/5] net: Validate IFLA_BRIDGE_MODE attribute length
Date: Wed, 26 Nov 2014 05:29:45 -0800
Message-ID: <CAL3LdT7pNbuX=-srsgf29iEu9N=NnhBJM_L=cr08XrP7w77pww@mail.gmail.com>
References: <cover.1417005245.git.tgraf@suug.ch>
	<4a88a0350064b5c2ec4e2adcef5afdfcab3e45dd.1417005245.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:63892 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbaKZN3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 08:29:45 -0500
Received: by mail-oi0-f51.google.com with SMTP id e131so1982305oig.38
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 05:29:45 -0800 (PST)
In-Reply-To: <4a88a0350064b5c2ec4e2adcef5afdfcab3e45dd.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 4:42 AM, Thomas Graf <tgraf@suug.ch> wrote:
> Payload is currently accessed blindly and may exceed valid message
> boundaries.
>
> Fixes: a77dcb8c8 ("be2net: set and query VEB/VEPA mode of the PF interface")
> Fixes: 815cccbf1 ("ixgbe: add setlink, getlink support to ixgbe and ixgbevf")
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c   | 3 +++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +++
>  2 files changed, 6 insertions(+)
>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
