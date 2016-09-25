From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] Revert "net: ethernet: bcmgenet: use phydev from
 struct net_device"
Date: Sun, 25 Sep 2016 08:30:34 -0700
Message-ID: <369f299b-46ab-7d5e-14b4-8044649b41ed@gmail.com>
References: <1474772772-5544-1-git-send-email-f.fainelli@gmail.com>
 <20160925.053531.2196576594458792866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, jaedon.shin@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33485 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938905AbcIYPdA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 11:33:00 -0400
Received: by mail-oi0-f65.google.com with SMTP id w11so12085011oia.0
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 08:33:00 -0700 (PDT)
In-Reply-To: <20160925.053531.2196576594458792866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/09/2016 à 02:35, David Miller a écrit :
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Sat, 24 Sep 2016 20:06:12 -0700
> 
>> This reverts commit 62469c76007e ("net: ethernet: bcmgenet: use phydev
>> from struct net_device") because it causes GENETv1/2/3 adapters to
>> expose the following behavior after an ifconfig down/up sequence:
> 
> This breaks the conversion of this driver to ethtool ksettings.

I must be missing something here, the proposed patch passes priv->phydev
to the ethtool ksettings helpers, is there something else that needs to
be taken care of?

Sorry for being slow to understand here...
-- 
Florian
