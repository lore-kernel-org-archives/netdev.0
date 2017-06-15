From: Jason Cobham <jcobham@questertangent.com>
Subject: RE: [PATCH net-next] net: dsa: add cross-chip multicast support
Date: Thu, 15 Jun 2017 16:33:51 -0700
Message-ID: <E5E6875F0BF25A4593C06E471C515D8636D3A2B6D9@magpie>
References: <20170615201448.22424-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: 'Vivien Didelot' <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615201448.22424-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/15/2017 1:15 PM, Vivien Didelot wrote:
> Similarly to how cross-chip VLAN works, define a bitmap of multicast group
> members for a switch, now including its DSA ports, so that multicast traffic
> can be sent to all switches of the fabric.
> 
> A switch may drop the frames if no user port is a member.
> 
> This brings support for multicast in a multi-chip environment.
> As of now, all switches of the fabric must support the multicast operations in
> order to program a single fabric port.
> 
> Reported-by: Jason Cobham <jcobham@questertangent.com>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks for this fix:

Tested-by: Jason Cobham <jcobham@questertangent.com>
--
Jason
