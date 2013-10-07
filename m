From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] IPv6: Allow the MTU of ipip6 tunnel to be set below
 1280
Date: Mon, 07 Oct 2013 12:33:24 -0400 (EDT)
Message-ID: <20131007.123324.1905399400311888938.davem@davemloft.net>
References: <1380808166-13280-1-git-send-email-ou.ghorbel@gmail.com>
	<20131004133223.GA11410@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ou.ghorbel@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131004133223.GA11410@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 4 Oct 2013 15:32:23 +0200

> On Thu, Oct 03, 2013 at 02:49:26PM +0100, Oussama Ghorbel wrote:
>> The (inner) MTU of a ipip6 (IPv4-in-IPv6) tunnel cannot be set below 1280, which is the minimum MTU in IPv6.
>> However, there should be no IPv6 on the tunnel interface at all, so the IPv6 rules should not apply.
>> More info at https://bugzilla.kernel.org/show_bug.cgi?id=15530
>> 
>> This patch allows to check the minimum MTU for ipv6 tunnel according to these rules:
>> -In case the tunnel is configured with ipip6 mode the minimum MTU is 68.
>> -In case the tunnel is configured with ip6ip6 or any mode the minimum MTU is 1280.
>> 
>> Signed-off-by: Oussama Ghorbel <ou.ghorbel@gmail.com>
 ...
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, but please do not capitalize "IPv6" when using it as a subsystem
prefix in Subject lines.

Thanks.
