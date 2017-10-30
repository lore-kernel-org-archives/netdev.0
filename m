From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/7] net: dsa: get ports within parsing code
Date: Mon, 30 Oct 2017 11:37:28 -0700
Message-ID: <f7185350-d43a-8b33-d725-6cf81171814d@gmail.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
 <20171027195519.5931-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/2017 12:55 PM, Vivien Didelot wrote:
> There is no point into hiding the -EINVAL error code in ERR_PTR from a
> dsa_get_ports function, simply get the "ports" node directly from within
> the dsa_parse_ports_dn function.
> 
> This also has the effect to make the pdata and device tree handling code
> symmetrical inside _dsa_register_switch.
> 
> At the same time, rename dsa_parse_ports_dn to dsa_parse_ports_of
> because _of is a more common suffix for device tree parsing functions.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
