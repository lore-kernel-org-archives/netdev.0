From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 01/20] net: dsa: change scope of STP state setter
Date: Mon, 22 May 2017 12:23:17 -0700
Message-ID: <e226634d-06ec-9420-e9d8-0685ba672305@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33385 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757576AbdEVTXV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 15:23:21 -0400
In-Reply-To: <20170519210055.9366-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> Instead of having multiple STP state helpers scoping a slave device
> supporting both the DSA logic and the switchdev binding, provide a
> single dsa_port_set_state helper scoping a DSA port, as well as its
> dsa_port_set_state_now wrapper which skips the prepare phase.
> 
> This allows us to better separate the DSA logic from the slave device
> handling.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
