From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Wed, 18 Dec 2013 08:48:04 +0800
Message-ID: <52B0F0C4.1010803@cn.fujitsu.com>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com> <52AFC43C.9080804@cn.fujitsu.com> <CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com> <52AFE7E3.3070806@cn.fujitsu.com> <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com> <20131217070231.GA11970@order.stressinduktion.org> <52B00150.3070002@cn.fujitsu.com> <20131217134823.GC18396@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: RongQing Li <roy.qing.li@gmail.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:2093 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750872Ab3LRArH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 19:47:07 -0500
In-Reply-To: <20131217134823.GC18396@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 09:48 PM, Hannes Frederic Sowa wrote:
> On Tue, Dec 17, 2013 at 03:46:24PM +0800, Gao feng wrote:
>> The from of new cloned rt should not be set if it's impossible for the ort
>> to be expired.
> 
> Actually, why do you think so? What could go wrong?
> 

I just don't want rt6_check_expired to check some impossible expired routes.
