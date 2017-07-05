From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC 02/12] net: dsa: Remove prepare phase for FDB
Date: Wed, 5 Jul 2017 12:25:43 -0700
Message-ID: <65318e63-77fb-c06f-b752-54faaee5a0ec@gmail.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-3-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, stephen@networkplumber.org,
        mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35135 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752139AbdGET0D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 15:26:03 -0400
Received: by mail-wr0-f196.google.com with SMTP id z45so51124584wrb.2
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 12:26:02 -0700 (PDT)
In-Reply-To: <1499268990-19251-3-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2017 08:36 AM, Arkadi Sharshevsky wrote:
> The prepare phase for FDB add is unneeded because most of DSA devices
> can have failures during bus transactions (SPI, I2C, etc.), thus, the
> prepare phase cannot guarantee success of the commit stage.
> 
> The support for learning FDB through notification chain, which will be
> introduced in the following patches, will provide the ability to notify
> back the bridge about successful offload.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
