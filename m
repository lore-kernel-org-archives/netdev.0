From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: ethernet: nb8800: Handle all 4 RGMII modes
 identically
Date: Tue, 25 Jul 2017 21:27:36 -0700 (PDT)
Message-ID: <20170725.212736.1112804111379770636.davem@davemloft.net>
References: <40478d08-8612-b3ab-63eb-24d12da0423f@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, mans@mansr.com,
        netdev@vger.kernel.org, slash.tmp@free.fr
To: marc_gonzalez@sigmadesigns.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751365AbdGZE1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 00:27:37 -0400
In-Reply-To: <40478d08-8612-b3ab-63eb-24d12da0423f@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Date: Tue, 25 Jul 2017 14:35:03 +0200

> Before commit bf8f6952a233 ("Add blurb about RGMII") it was unclear
> whose responsibility it was to insert the required clock skew, and
> in hindsight, some PHY drivers got it wrong. The solution forward
> is to introduce a new property, explicitly requiring skew from the
> node to which it is attached. In the interim, this driver will handle
> all 4 RGMII modes identically (no skew).
> 
> Fixes: 52dfc8301248 ("net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller")
> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>

Applied and queued up for -stable, thanks!
