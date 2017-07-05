From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 03/12] net: dsa: Remove switchdev dependency
 from DSA switch notifier chain
Date: Wed, 5 Jul 2017 12:26:20 -0700
Message-ID: <2742a196-bf22-d4ca-5b61-a9381cb90009@gmail.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-4-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, stephen@networkplumber.org,
        mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33816 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751703AbdGET02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 15:26:28 -0400
Received: by mail-wr0-f194.google.com with SMTP id k67so50846606wrc.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 12:26:27 -0700 (PDT)
In-Reply-To: <1499268990-19251-4-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2017 08:36 AM, Arkadi Sharshevsky wrote:
> Currently, the switchdev objects are embedded inside the DSA notifier
> info. This patch removes this dependency. This is done as a preparation
> stage before adding support for learning FDB through the switchdev
> notification chain.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
