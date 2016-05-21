From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH 2/2] ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit path.
Date: Sat, 21 May 2016 11:46:29 +0800
Message-ID: <757BA329-0E68-4D1F-8F7C-A9082B323CA8@cmss.chinamobile.com>
References: <1463565952-8781-1-git-send-email-yanhaishuang@cmss.chinamobile.com> <1463565952-8781-2-git-send-email-yanhaishuang@cmss.chinamobile.com> <20160520.104835.678619743450630862.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:5365 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbcEUDqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 23:46:35 -0400
In-Reply-To: <20160520.104835.678619743450630862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On May 21, 2016, at 1:48 AM, David Miller <davem@davemloft.net> wrote:
> 
> From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> Date: Wed, 18 May 2016 18:05:52 +0800
> 
>> In gre6 xmit path, we are sending a GRE packet, so set fl6 proto
>> to IPPROTO_GRE properly.
>> 
>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> I think it would be a lot better to initialize the flow protocol field
> properly in ip6gre_tnl_link_config() instead of fixing it up every
> single transmit.
> 
> 

I agree, I will modify the changes in v2.

Thanks

Haishuang
