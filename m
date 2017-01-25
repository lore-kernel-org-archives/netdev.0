From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Documentation: devicetree: change the mediatek
 ethernet compatible string
Date: Wed, 25 Jan 2017 14:36:13 -0500 (EST)
Message-ID: <20170125.143613.634538648038125925.davem@davemloft.net>
References: <1485332455-34743-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, matthias.bgg@gmail.com, netdev@vger.kernel.org,
        sean.wang@mediatek.com, devicetree@vger.kernel.org,
        linux-mediatek@lists.infradead.org
To: john@phrozen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751446AbdAYTgQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:36:16 -0500
In-Reply-To: <1485332455-34743-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <john@phrozen.org>
Date: Wed, 25 Jan 2017 09:20:54 +0100

> When the binding was defined, I was not aware that mt2701 was an earlier
> version of the SoC. For sake of consistency, the ethernet driver should
> use mt2701 inside the compat string as this is the earliest SoC with the
> ethernet core.
> 
> The ethernet driver is currently of no real use until we finish and
> upstream the DSA driver. There are no users of this binding yet. It should
> be safe to fix this now before it is too late and we need to provide
> backward compatibility for the mt7623-eth compat string.
> 
> Reported-by: Sean Wang <sean.wang@mediatek.com>
> Signed-off-by: John Crispin <john@phrozen.org>

Applied.
