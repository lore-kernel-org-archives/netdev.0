From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] updated, ethernet-bridge: update skb->priority in case
 forwarded frame has VLAN-header
Date: Fri, 11 Mar 2005 09:37:24 -0800
Message-ID: <20050311093724.6c8b6a6d@dxpl.pdx.osdl.net>
References: <914610115.20050311172022@yuriev.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Ben Greear <greearb@candelatech.com>, <netdev@oss.sgi.com>,
	<linux-kernel@vger.kernel.org>
To: "leo.yuriev.ru" <leo@yuriev.ru>
In-Reply-To: <914610115.20050311172022@yuriev.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Mar 2005 17:20:22 +0300
Leo Yuriev <leo@yuriev.ru> wrote:

> Kernel 2.6 (2.6.11)
> 
> When ethernet-bridge forward a packet and such ethernet-frame has
> VLAN-tag, bridge should update skb->prioriry for properly QoS
> handling. This small patch does this.
> 
> Based upon discussion during last week I added pskb_may_pull()
> checking and simple mapping from 802.1p/user_priority to skb->priority.
> 
> Patch-by: Leo Yuriev <leo@yuriev.ru>

Do this as an ebtables module please.
