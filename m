From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: Fix crash on DT systems
Date: Thu, 02 Mar 2017 12:47:58 -0800 (PST)
Message-ID: <20170302.124758.1985678419997358947.davem@davemloft.net>
References: <20170228170855.8123-1-alban.bedel@avionic-design.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isubramanian@apm.com, kchudgar@apm.com,
        linux-kernel@vger.kernel.org
To: alban.bedel@avionic-design.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdCBVBq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 16:01:46 -0500
In-Reply-To: <20170228170855.8123-1-alban.bedel@avionic-design.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alban Bedel <alban.bedel@avionic-design.de>
Date: Tue, 28 Feb 2017 18:08:55 +0100

> On DT systems the driver require a clock, but the probe just print a
> warning and continue, leading to a crash when resetting the device.
> To fix this crash and properly handle probe deferals only ignore the
> missing clock if DT isn't used or if the clock doesn't exist.
> 
> Signed-off-by: Alban Bedel <alban.bedel@avionic-design.de>

Applied, thanks.
