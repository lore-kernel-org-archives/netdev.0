From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/9] net: dsa: fix dsa_is_normal_port helper
Date: Thu, 26 Oct 2017 16:08:42 -0700
Message-ID: <64885aa8-424a-baba-e2a7-9178d3363d73@gmail.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
 <20171026152259.3123-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026152259.3123-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/2017 08:22 AM, Vivien Didelot wrote:
> In order to know if a port is of type user, dsa_is_normal_port checks
> that the given port is not of type DSA nor CPU. This is not enough
> because a port can be unused.
> 
> Without the previous fix, this caused the unused mv88e6xxx ports to be
> configured in normal mode.
> 
> The ds->enabled_port_mask reports the user ports, so check this instead.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
