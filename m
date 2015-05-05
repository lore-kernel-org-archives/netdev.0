From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net V1] ethtool: Support for configurable RSS hash function
Date: Tue, 5 May 2015 18:48:27 +0300
Message-ID: <CAPcc5PigfcBCZV=z+Q15+0xBXh_GEyGEz6RASPCXtQvTXadP0w@mail.gmail.com>
References: <1430133773-11613-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Eyal Perry <eyalpe@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:34017 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993463AbbEEPs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 11:48:29 -0400
Received: by laat2 with SMTP id t2so130904164laa.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 08:48:27 -0700 (PDT)
In-Reply-To: <1430133773-11613-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2015 at 2:22 PM, Amir Vadai <amirv@mellanox.com> wrote:
> From: Eyal Perry <eyalpe@mellanox.com>
>
> This ethtool patch adds support to set and get the current RSS hash
> function for the device through through the new hfunc field in the
> ethtool_rxfh struct. Kernel supported hash function names are queried
> with ETHTOOL_GSTRINGS (value 0 is reserved and skipped).
>
> Although currently no device supports a combination of hash
> functions/attributes, this ethtool implementation will support it. Both in the
> set and in the get.
> The device driver declares the functions and/or attributes that it supports,
> and ethtool will show it correctly and enable the user to set those
> combinations.
> If a combination is not supported - the device driver will fail the operation
> and ethtool will print an error message.
>
> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
> Changes from V1:
> - Fixed some English mistakes
> - Fixed the complicated way to write '= req_hfunc;'...
> - Better support in combination of hash functions/attributes

Ben Hi,

Could you take a look at this patch?

Thanks,
Amir
