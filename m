From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net 4/7] nfp: Initialize RX and TX ring 64-bit stats
 seqcounts
Date: Tue, 1 Aug 2017 22:04:22 +0200
Message-ID: <20170801200421.GB9845@vergenet.net>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
 <20170801191113.8754-5-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "open list:NETRONOME ETHERNET DRIVERS" <oss-drivers@netronome.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170801191113.8754-5-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 12:11:09PM -0700, Florian Fainelli wrote:
> On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
> lockdep splat indicating this seqcount is not correctly initialized, fix
> that.
> 
> Fixes: 4c3523623dc0 ("net: add driver for Netronome NFP4000/NFP6000 NIC VFs")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>

FYI, Jakub is on leave this week.
