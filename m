From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: store CPU port pointer in the tree
Date: Tue, 16 May 2017 22:42:32 +0200
Message-ID: <20170516204232.GA11625@lunn.ch>
References: <20170516181033.19980-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170516181033.19980-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 02:10:33PM -0400, Vivien Didelot wrote:
> A dsa_switch_tree instance holds a dsa_switch pointer and a port index
> to identify the switch port to which the CPU is attached.
> 
> Now that the DSA layer has a dsa_port structure to hold this data, use
> it to point the switch CPU port.
> 
> This patch simply substitutes s/dst->cpu_switch/dst->cpu_dp->ds/ and
> s/dst->cpu_port/dst->cpu_dp->index/.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
