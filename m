From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 8/8] net: bcmgenet: decouple flow control from
 bcmgenet_tx_reclaim
Date: Thu, 9 Mar 2017 17:45:08 -0800
Message-ID: <21e3ffb2-cf23-0c55-c5f7-dd711d8332e1@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
 <20170310005850.10808-9-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-9-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 04:58 PM, Doug Berger wrote:
> The bcmgenet_tx_reclaim() function is used to reclaim transmit
> resources in different places within the driver.  Most of them
> should not affect the state of the transmit flow control.
> 
> This commit relocates the logic for waking tx queues based on
> freed resources to the napi polling function where it is more
> appropriate.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
