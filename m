From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v3 00/12] bnxt_en: Add XDP support.
Date: Mon, 6 Feb 2017 17:41:29 -0800
Message-ID: <20170206174129.6e56445b@cakuba.netronome.com>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:8085 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751870AbdBGBlw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 20:41:52 -0500
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  6 Feb 2017 16:55:31 -0500, Michael Chan wrote:
> The first 10 patches refactor the code (rx/tx code paths and ring logic)
> and add the basic infrastructure to support XDP.  The 11th patch adds
> basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 12th patch
> completes the series with XDP_TX.
> 
> Thanks to Andy Gospodarek for testing and uncovering some bugs.
> 
> v3: Removed Kconfig option.
>     Pass modified offset and length to stack for XDP_PASS.

Looks correct now, thanks!
