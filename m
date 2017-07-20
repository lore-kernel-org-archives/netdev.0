From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: systemport: Support 64bit statistics
Date: Wed, 19 Jul 2017 22:25:16 -0700 (PDT)
Message-ID: <20170719.222516.1490852598794069450.davem@davemloft.net>
References: <1500423520-4169-1-git-send-email-jqiaoulk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: jqiaoulk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932732AbdGTFZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 01:25:17 -0400
In-Reply-To: <1500423520-4169-1-git-send-email-jqiaoulk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jianming.qiao" <jqiaoulk@gmail.com>
Date: Wed, 19 Jul 2017 01:18:40 +0100

> Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>

Supporting both deprecated .ndo_get_stats and 64-bit .ndo_get_stats64
at the same time makes no sense.

.ndo_get_stats will never be called if .ndo_get_stats64 is non-NULL

The lack of a commit log message, explaining in detail, why you are
doing this and why you are doing it this way, concerns me as well.

This submission so far has been a bit of a mess.  You don't
communicate enough, your commit message is empty, and therefore we
have no idea why you are doing things, and in particular the reasons
for your decisions.

I'm not applying this, sorry.
