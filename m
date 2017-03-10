From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 04/14] net: dsa: mv88e6xxx: rework ATU Load/Purge
Date: Fri, 10 Mar 2017 03:27:48 +0100
Message-ID: <20170310022748.GI22101@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170309233324.18539-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 09, 2017 at 06:33:14PM -0500, Vivien Didelot wrote:
> All Marvell switch chips have an ATU accessed using the same Global (1)
> register layout. Only the handling of the FID differs as more bits were
> necessary to support more and more databases.
> 
> Add and use a fresh documented implementation of the ATU Load/Purge.

This is not really the Linux way of doing something. You don't throw
something away and replace it. You incrementally modify what you have
into something better.

I really wished you had moved the code, unmodified, into
global1_atu.c. Then made lots of easy to review small changes. I
cannot just look at this patch and know it is correct. What i need to
compare against is not in this patch. So it is a lot harder to review.

I will continue this review later...

  Andrew
