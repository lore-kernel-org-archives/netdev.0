From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 7/9] net: dsa: define port types
Date: Thu, 26 Oct 2017 17:36:11 +0200
Message-ID: <20171026153611.GG1928@nanopsycho.orion>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
 <20171026152259.3123-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171026152259.3123-8-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Oct 26, 2017 at 05:22:57PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Introduce an enumerated type for ports, which will be way more explicit
>to identify a port type instead of digging into switch port masks.
>
>A port can be of type CPU, DSA, user, or unused by default. This is a
>static parsed information that cannot be changed at runtime.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>---
> include/net/dsa.h | 7 +++++++
> net/dsa/dsa2.c    | 3 +++
> net/dsa/legacy.c  | 6 ++++++
> 3 files changed, 16 insertions(+)
>
>diff --git a/include/net/dsa.h b/include/net/dsa.h
>index dc7728062396..8da20c4a6552 100644
>--- a/include/net/dsa.h
>+++ b/include/net/dsa.h
>@@ -180,6 +180,13 @@ struct dsa_port {
> 	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
> 			       struct packet_type *pt);
> 
>+	enum {
>+		DSA_PORT_TYPE_UNUSED = 0,
>+		DSA_PORT_TYPE_CPU,
>+		DSA_PORT_TYPE_DSA,
>+		DSA_PORT_TYPE_USER,

Do you plan to expose this to userspace? How?
