From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 1/7] net: dsa: add master helper to look up
 slaves
Date: Fri, 29 Sep 2017 18:14:36 -0700
Message-ID: <da94a05d-8523-b2ad-21e1-470cddf669a7@gmail.com>
References: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
 <20170929211921.5571-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929211921.5571-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09/29/2017 02:19 PM, Vivien Didelot wrote:
> The DSA tagging code does not need to know about the DSA architecture,
> it only needs to return the slave device corresponding to the source
> port index (and eventually the source device index for cascade-capable
> switches) parsed from the frame received on the master device.
> 
> For this purpose, provide an inline dsa_master_get_slave helper which
> validates the device and port indexes and look up the slave device.
> 
> This makes the tagging rcv functions more concise and robust, and also
> makes dsa_get_cpu_port obsolete.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
