From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/9] net: dsa: add dsa_is_unused_port helper
Date: Thu, 26 Oct 2017 16:07:44 -0700
Message-ID: <23326961-af26-4865-14a1-6c284d530757@gmail.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
 <20171026152259.3123-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026152259.3123-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/2017 08:22 AM, Vivien Didelot wrote:
> As the comment above the chunk states, the b53 driver attempts to
> disable the unused ports. But using ds->enabled_port_mask is misleading,
> because this mask reports in fact the user ports.
> 
> To avoid confusion and fix this, this patch introduces an explicit
> dsa_is_unused_port helper which ensures the corresponding bit is not
> masked in any of the switch port masks.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
