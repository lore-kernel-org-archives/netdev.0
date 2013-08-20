From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] vxlan: using kfree_rcu() to simplify the code
Date: Tue, 20 Aug 2013 15:06:02 -0700 (PDT)
Message-ID: <20130820.150602.458021346277301822.davem@davemloft.net>
References: <CAPgLHd8gtuhjrPP-t0dHGj_BDY5WqqX-QQbHpNK+0gPpuSN9LQ@mail.gmail.com>
	<20130816164544.628ae1df@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, pshelar@nicira.com,
	mike.rapoport@ravellosystems.com, amwang@redhat.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab3HTWGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 18:06:03 -0400
In-Reply-To: <20130816164544.628ae1df@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 16 Aug 2013 16:45:44 -0700

> On Sat, 17 Aug 2013 07:32:09 +0800
> Wei Yongjun <weiyj.lk@gmail.com> wrote:
> 
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> 
>> The callback function of call_rcu() just calls a kfree(), so we
>> can use kfree_rcu() instead of call_rcu() + callback function.
>> 
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
 ...
> Acked-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
