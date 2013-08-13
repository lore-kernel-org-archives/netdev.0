From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: rtnl_bridge_getlink: Call nlmsg_find_attr()
 with ifinfomsg header
Date: Tue, 13 Aug 2013 15:54:43 -0700 (PDT)
Message-ID: <20130813.155443.1789890841731289313.davem@davemloft.net>
References: <52090C26.4090001@fiberby.net>
	<1376325009-8399-1-git-send-email-ast@fiberby.net>
	<52093E29.5010604@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fiberby.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52093E29.5010604@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon, 12 Aug 2013 15:57:29 -0400

> On 08/12/2013 12:30 PM, Asbjoern Sloth Toennesen wrote:
>> Fix the iproute2 command `bridge vlan show`, after switching from
>> rtgenmsg to ifinfomsg.
>>
>> Signed-off-by: Asbjoern Sloth Toennesen <ast@fiberby.net>
> 
> 
> Thanks..  I've still been using an older iproute version and didn't
> see this.
> 
> 
> Reviewed-by: Vlad Yasevich <vyasevich@gmail.com>

What introduced this regression?
