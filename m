From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net 2/3] mlxsw: spectrum: Do not override PAUSE settings
Date: Mon, 8 Aug 2016 18:29:34 +0200
Message-ID: <20160808162934.GM1944@nanopsycho.orion>
References: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
 <1470321382-10426-3-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35857 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbcHHQ3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 12:29:37 -0400
Received: by mail-wm0-f67.google.com with SMTP id x83so16461167wma.3
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 09:29:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1470321382-10426-3-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 04, 2016 at 04:36:21PM CEST, idosch@mellanox.com wrote:
>The PFCC register is used to configure both PAUSE and PFC frames.
>Therefore, when PFC frames are disabled we must make sure we don't
>mistakenly also disable PAUSE frames (which might be enabled).
>
>Fix this by packing the PFCC register with the current PAUSE settings.
>
>Note that this register is also accessed via ethtool ops, but there we
>are guaranteed to have PFC disabled.
>
>Fixes: d81a6bdb87ce ("mlxsw: spectrum: Add IEEE 802.1Qbb PFC support")
>Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
