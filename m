From: Patrick McHardy <kaber@trash.net>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
 in case forwarded frame has VLAN-header]
Date: Mon, 07 Mar 2005 19:16:50 +0100
Message-ID: <422C9A92.6040902@trash.net>
References: <20050305141225.GA5180@xi.wantstofly.org> <20050307100744.429e100a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050307100744.429e100a@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>>
>>This small patch does this. Currently vlan_TCI-priority directly
>>mapped to skb->priority, but this looks enough.
> 
> I don't see why the VLAN code doesn't handle this itself. I don't like special
> case layer violations because it becomes a slippery slope with more and
> more additions.

The patch is meant for bridges briging vlan frames without doing
vlan themselves. I agree with you, from the bridge point of view
a vlan header is just as outside of its scope as an IP header,
that's why I proposed to put it in an ebtables target and make
it useable for vlan and IP.

Regards
Patrick
