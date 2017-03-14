From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 08/12] net: bcmgenet: correct return value of
 __bcmgenet_tx_reclaim
Date: Mon, 13 Mar 2017 17:57:36 -0700
Message-ID: <81581ab7-8c75-d020-f31b-60829c3f089b@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-9-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-9-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 05:41 PM, Doug Berger wrote:
> The reclaim function should return the number of buffer descriptors
> reclaimed, not just the number corresponding to skb packets.
> 
> Also, remove the unnecessary computation when updating the consumer
> index.
> 
> While this is not a functional problem it could degrade performance
> of napi in a fragmented transmit stream.
> 
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
