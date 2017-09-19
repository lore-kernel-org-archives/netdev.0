From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/4] net: dsa: move master ethtool code
Date: Tue, 19 Sep 2017 12:56:13 -0700
Message-ID: <b53830f3-e5d7-a8c0-befd-ebf342a70acd@gmail.com>
References: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
 <20170919155700.14474-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919155700.14474-5-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/19/2017 08:57 AM, Vivien Didelot wrote:
> DSA overrides the master device ethtool ops, so that it can inject stats
> from its dedicated switch CPU port as well.
> 
> The related code is currently split in dsa.c and slave.c, but it only
> scopes the master net device. Move it to a new master.c DSA core file.
> 
> This file will be later extented with master net device specific code.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
