From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 3/8] net: bcmgenet: reserved phy revisions must be
 checked first
Date: Thu, 9 Mar 2017 17:43:22 -0800
Message-ID: <a112f921-1e6f-73ed-c662-d5871eca538e@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
 <20170310005850.10808-4-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-4-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 04:58 PM, Doug Berger wrote:
> The reserved gphy_rev value of 0x01ff must be tested before the old
> or new scheme for GPHY major versioning are tested, otherwise it will
> be treated as 0xff00 according to the old scheme.
> 
> Fixes: b04a2f5b9ff5 ("net: bcmgenet: add support for new GENET PHY revision scheme")
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
