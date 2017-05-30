From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/7] net: dsa: free orig skb on rcv if
 reallocated
Date: Tue, 30 May 2017 17:25:05 +0200
Message-ID: <20170530152505.GG22758@lunn.ch>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
 <20170530142131.23568-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170530142131.23568-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 10:21:28AM -0400, Vivien Didelot wrote:
> If the receive function of a tagger reallocated the SKB, the original
> SKB is currently not freed. Fix this and free it on both copy or error.

I don't see any of the receive functions reallocate the skb. It might
be better to just simplify the code to take away the option to return
a different skb.

  Andrew
