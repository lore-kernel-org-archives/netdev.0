From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 01/11] net: dsa: PHY device is mandatory for
 EEE
Date: Tue, 1 Aug 2017 14:31:00 -0700
Message-ID: <1e4a5f28-4673-8eda-96ab-fffa02d4d4e7@gmail.com>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
 <20170801203241.22294-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801203241.22294-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01/2017 01:32 PM, Vivien Didelot wrote:
> The port's PHY and MAC are both implied in EEE. The current code does
> not call the PHY operations if the related device is NULL. Change that
> by returning -ENODEV if there's no PHY device attached to the interface.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
