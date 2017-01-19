From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v7 00/13] net: ethernet: aquantia: Add AQtion 2.5/5 GB NIC
 driver
Date: Thu, 19 Jan 2017 14:41:26 -0800
Message-ID: <13303162-471c-de9c-a222-6bdbf5f38db9@gmail.com>
References: <cover.1484860589.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35348 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753608AbdASWl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:41:29 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so5166900pge.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 14:41:29 -0800 (PST)
In-Reply-To: <cover.1484860589.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2017 01:33 PM, Alexander Loktionov wrote:
> From: David VomLehn <vomlehn@texas.net>
> 
> This series introduces the AQtion NIC driver for the aQuantia
> AQC107/AQC108 network devices.

> v5: o Removed extra newline at the end of the files.
> v6: o Removed unnecessary cast from void*.
>     o Reworked strings array for ethtool statistics.
>     o Added stringset == ETH_SS_STATS checking.
>     o AQ_OBJ_HEADER replaced to aq_obj_header_s struct.
>     o AQ_OBJ_SET/TST/CLR macroses replaced to inline functions.
>     o Driver sources placed in to atlantic directory.
>     o Fixed compilation warnings (Make W=1)
>     o Added firmware version checking.
>     o Code cleaning.
> v7  o Removed unnecessary cast from memory allocation function (aq_ring.c).

In general, you may want for a couple of days before resubmitting new
versions that only fix minor stuff like what happened here between v6
and v7.

Some general comments on the coding style, it is usually preferred not
to name a structure e.g; struct foo_s, but just struct foo, you are also
saving bytes (and therefore trees!).
-- 
Florian
