From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 5/7] net: dsa: get master device at port parsing
 time
Date: Mon, 30 Oct 2017 11:41:36 -0700
Message-ID: <7df77001-9907-f030-daa5-31bad4c8b12a@gmail.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
 <20171027195519.5931-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-6-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/2017 12:55 PM, Vivien Didelot wrote:
> Fetching the master device can be done directly when a port is parsed
> from device tree or pdata, instead of waiting until dsa_dst_parse.
> 
> Now that -EPROBE_DEFER is returned before we add the switch to the tree,
> there is no need to check for this error after dsa_dst_parse.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
