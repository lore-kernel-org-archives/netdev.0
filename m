From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] openvswitch: Fix L4 checksum handling when dealing
 with IP fragments
Date: Mon, 03 Aug 2015 14:03:28 -0700 (PDT)
Message-ID: <20150803.140328.574050334230752525.davem@davemloft.net>
References: <20150803165654.GA16892@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org,
	linux-kernel@vger.kernel.org
To: ggriffin.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150803165654.GA16892@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Glenn Griffin <ggriffin.kernel@gmail.com>
Date: Mon, 3 Aug 2015 09:56:54 -0700

> openvswitch modifies the L4 checksum of a packet when modifying
> the ip address. When an IP packet is fragmented only the first
> fragment contains an L4 header and checksum. Prior to this change
> openvswitch would modify all fragments, modifying application data
> in non-first fragments, causing checksum failures in the
> reassembled packet.
> 
> Signed-off-by: Glenn Griffin <ggriffin.kernel@gmail.com>
> ---
> Changes in v2:
>   - Compare frag_off in network byte order rather than host byte order

Applied and queued up for -stable.
