From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_tunnel: fix potential NULL pointer dereference
Date: Fri, 09 May 2014 13:19:40 -0400 (EDT)
Message-ID: <20140509.131940.1197122162710416387.davem@davemloft.net>
References: <1399660892-19008-1-git-send-email-susant@redhat.com>
	<20140509.131223.649558454524140168.davem@davemloft.net>
	<536D0DA8.10106@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: susant@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757036AbaEIRTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 13:19:42 -0400
In-Reply-To: <536D0DA8.10106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Susant Sahani <susant@redhat.com>
Date: Fri, 09 May 2014 22:47:28 +0530

> On 05/09/2014 10:42 PM, David Miller wrote:
>> From: Susant Sahani <susant@redhat.com>
>> Date: Sat, 10 May 2014 00:11:32 +0530
>>
>>> The function ip6_tnl_validate assumes that the rtnl
>>> attribute IFLA_IPTUN_PROTO always be filled . If this
>>> attribute is not filled by  the userspace application
>>> kernel get crashed with NULL pointer dereference. This
>>> patch fixes the potential kernel crash when
>>> IFLA_IPTUN_PROTO is missing .
>>>
>>> Signed-off-by: Susant Sahani <susant@redhat.com>
>>> Acked-by: Thomas Graf <tgraf@suug.ch>
>> You really need to fix the date on your computer, it was not
>> Saturday May 10th when you submitted this patch.
> Do you want me to resend it again ?

It's not necessary this time, but just realize that this makes my work
harder because your patch looked like the most recent one submitted in
patchwork because the date was always newer than anything else being
submitted meanwhile.
