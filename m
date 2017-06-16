From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: add cross-chip multicast support
Date: Fri, 16 Jun 2017 15:21:54 -0400 (EDT)
Message-ID: <20170616.152154.1388838024873603347.davem@davemloft.net>
References: <20170615201448.22424-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        jcobham@questertangent.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615201448.22424-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 15 Jun 2017 16:14:48 -0400

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

Applied, thanks Vivien.
