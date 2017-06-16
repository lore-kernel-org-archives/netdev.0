From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: add cross-chip multicast support
Date: Thu, 15 Jun 2017 17:34:27 -0700
Message-ID: <52745077-effa-1592-5ab1-2778b394cf91@gmail.com>
References: <20170615201448.22424-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615201448.22424-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/15/2017 01:14 PM, Vivien Didelot wrote:
> Similarly to how cross-chip VLAN works, define a bitmap of multicast
> group members for a switch, now including its DSA ports, so that
> multicast traffic can be sent to all switches of the fabric.
> 
> A switch may drop the frames if no user port is a member.
> 
> This brings support for multicast in a multi-chip environment.
> As of now, all switches of the fabric must support the multicast
> operations in order to program a single fabric port.
> 
> Reported-by: Jason Cobham <jcobham@questertangent.com>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
