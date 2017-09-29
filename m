From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 7/8] net: dsa: change dsa_ptr for a dsa_port
Date: Fri, 29 Sep 2017 12:20:25 -0700
Message-ID: <767d2ab8-7fc1-170b-ec13-07c77158d4e3@gmail.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
 <20170929183635.8122-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929183635.8122-8-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2017 11:36 AM, Vivien Didelot wrote:
> With DSA, a master net device (CPU facing interface) has a dsa_ptr
> pointer to which hangs a dsa_switch_tree. This is not correct because a
> master interface is wired to a dedicated switch port, and because we can
> theoretically have several master interfaces pointing to several CPU
> ports of the same switch fabric.
> 
> Change the master interface's dsa_ptr for the CPU dsa_port pointer.
> This is a step towards supporting multiple CPU ports. Also remove
> dsa_get_cpu_port which is now unneeded.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
