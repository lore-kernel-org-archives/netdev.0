From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Wed, 18 Dec 2013 08:59:24 +0100
Message-ID: <20131218075924.GE27460@order.stressinduktion.org>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com> <52AFC43C.9080804@cn.fujitsu.com> <CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com> <52AFE7E3.3070806@cn.fujitsu.com> <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com> <20131217070231.GA11970@order.stressinduktion.org> <52B00150.3070002@cn.fujitsu.com> <20131217134823.GC18396@order.stressinduktion.org> <52B0F0C4.1010803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: RongQing Li <roy.qing.li@gmail.com>, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35570 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab3LRH7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:59:25 -0500
Content-Disposition: inline
In-Reply-To: <52B0F0C4.1010803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 08:48:04AM +0800, Gao feng wrote:
> On 12/17/2013 09:48 PM, Hannes Frederic Sowa wrote:
> > On Tue, Dec 17, 2013 at 03:46:24PM +0800, Gao feng wrote:
> >> The from of new cloned rt should not be set if it's impossible for the ort
> >> to be expired.
> > 
> > Actually, why do you think so? What could go wrong?
> > 
> 
> I just don't want rt6_check_expired to check some impossible expired routes.

Only for performance? It does not seem to do any harm?
