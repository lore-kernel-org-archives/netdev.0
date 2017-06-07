From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/5] net: dsa: check VLAN capability of every
 switch
Date: Wed, 7 Jun 2017 12:39:51 -0700
Message-ID: <8d6edbe3-a80b-6cc7-b7ec-d8f1578dea27@gmail.com>
References: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com>
 <20170606205631.22880-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36443 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdFGTj5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:39:57 -0400
In-Reply-To: <20170606205631.22880-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2017 01:56 PM, Vivien Didelot wrote:
> Now that the VLAN object is propagated to every switch chip of the
> switch fabric, we can easily ensure that they all support the required
> VLAN operations before modifying an entry on a single switch.
> 
> To achieve that, remove the condition skipping other target switches,
> and add a bitmap of VLAN members, eventually containing the target port,
> if we are programming the switch target.

You could add in the commit message that with this commit, there is not
actually a functional change yet because we have one (and only one) bit
set in the members bitmap.

> 
> This will allow us to easily add other VLAN members, such as the DSA or
> CPU ports (to introduce cross-chip VLAN support) or the other port
> members if we want to reduce hardware accesses later.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
