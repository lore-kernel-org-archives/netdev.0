From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 04/13] net: dsa: Add support for learning FDB
 through notification
Date: Mon, 7 Aug 2017 11:07:40 -0700
Message-ID: <33ca261b-7664-73fe-de96-81248948e2ad@gmail.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-5-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:37581 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751800AbdHGSHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:07:44 -0400
Received: by mail-qt0-f195.google.com with SMTP id d10so1213455qtb.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:07:43 -0700 (PDT)
In-Reply-To: <1502025351-41261-5-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2017 06:15 AM, Arkadi Sharshevsky wrote:
> Add support for learning FDB through notification. The driver defers
> the hardware update via ordered work queue. In case of a successful
> FDB add a notification is sent back to bridge.
> 
> In case of hw FDB del failure the static FDB will be deleted from
> the bridge, thus, the interface is moved to down state in order to
> indicate inconsistent situation.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
