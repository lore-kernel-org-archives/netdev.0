From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: dsa: remove copy of master ethtool_ops
Date: Tue, 19 Sep 2017 12:55:54 -0700
Message-ID: <af34cc71-a7bb-423f-fc43-d3e1579c1da0@gmail.com>
References: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
 <20170919155700.14474-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919155700.14474-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/19/2017 08:56 AM, Vivien Didelot wrote:
> There is no need to store a copy of the master ethtool ops, storing the
> original pointer in DSA and the new one in the master netdev itself is
> enough.
> 
> In the meantime, set orig_ethtool_ops to NULL when restoring the master
> ethtool ops and check the presence of the master original ethtool ops as
> well as its needed functions before calling them.

I clearly like memcpy() too much, this looks good:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
