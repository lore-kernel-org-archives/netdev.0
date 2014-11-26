From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 2/5] net: Validate IFLA_BRIDGE_MODE attribute length
Date: Wed, 26 Nov 2014 08:42:48 -0800
Message-ID: <54760308.8030708@gmail.com>
References: <cover.1417005245.git.tgraf@suug.ch> <4a88a0350064b5c2ec4e2adcef5afdfcab3e45dd.1417005245.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, Ajit Khaparde <ajit.khaparde@emulex.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:65221 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaKZQnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 11:43:05 -0500
Received: by mail-oi0-f43.google.com with SMTP id a3so2270815oib.30
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 08:43:04 -0800 (PST)
In-Reply-To: <4a88a0350064b5c2ec4e2adcef5afdfcab3e45dd.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2014 04:42 AM, Thomas Graf wrote:
> Payload is currently accessed blindly and may exceed valid message
> boundaries.
>
> Fixes: a77dcb8c8 ("be2net: set and query VEB/VEPA mode of the PF interface")
> Fixes: 815cccbf1 ("ixgbe: add setlink, getlink support to ixgbe and ixgbevf")
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>   drivers/net/ethernet/emulex/benet/be_main.c   | 3 +++
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +++
>   2 files changed, 6 insertions(+)
>

Thanks Thomas.

Acked-by: John Fastabend <john.r.fastabend@intel.com>


-- 
John Fastabend         Intel Corporation
