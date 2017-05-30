From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 5/6] net: dsa: remove out_drop label in
 taggers rcv
Date: Tue, 30 May 2017 13:48:47 -0700
Message-ID: <568dcfd0-21b0-1c20-680d-d29a29d7a976@gmail.com>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
 <20170530183319.10718-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530183319.10718-6-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/30/2017 11:33 AM, Vivien Didelot wrote:
> Many rcv functions from net/dsa/tag_*.c have a useless out_drop goto
> label which simply returns NULL. Kill it in favor of the obvious.

Why not

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
