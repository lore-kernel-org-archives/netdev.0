From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net/ipv4: ip_vti clear skb cb before tunneling.
Date: Thu, 13 Jun 2013 02:48:25 -0700 (PDT)
Message-ID: <20130613.024825.1735021953080018670.davem@davemloft.net>
References: <1370911510-20012-1-git-send-email-saurabh.mohan@vyatta.com>
	<20130610182822.0f37feb5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saumoh@gmail.com, netdev@vger.kernel.org, saurabh@vyatta.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203Ab3FMJs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:48:26 -0400
In-Reply-To: <20130610182822.0f37feb5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 10 Jun 2013 18:28:22 -0700

> On Mon, 10 Jun 2013 17:45:10 -0700
> Saurabh Mohan <saumoh@gmail.com> wrote:
> 
>> From: Saurabh Mohan <saurabh@vyatta.com>
>> 
>> If users apply shaper to vti tunnel then it will cause a kernel crash. The
>> problem seems to be due to the vti_tunnel_xmit function not clearing
>> skb->opt field before passing the packet to xfrm tunneling code.
>> 
>> Signed-off-by: Saurabh Mohan <saurabh@vyatta.com>
 ...
> Thanks, this applies to 3.9 and earlier kernels. When the tunnel code was unified,
> this was fixed in ip_tunnel.c
> 
> Acked-by: Stephen Hemminger <stephen@networkplumber.org>

Applied and queued up for -stable, thanks.
