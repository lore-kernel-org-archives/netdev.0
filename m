From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Tue, 17 Dec 2013 14:48:23 +0100
Message-ID: <20131217134823.GC18396@order.stressinduktion.org>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com> <52AFC43C.9080804@cn.fujitsu.com> <CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com> <52AFE7E3.3070806@cn.fujitsu.com> <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com> <20131217070231.GA11970@order.stressinduktion.org> <52B00150.3070002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: RongQing Li <roy.qing.li@gmail.com>, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33422 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408Ab3LQNsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 08:48:24 -0500
Content-Disposition: inline
In-Reply-To: <52B00150.3070002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 03:46:24PM +0800, Gao feng wrote:
> The from of new cloned rt should not be set if it's impossible for the ort
> to be expired.

Actually, why do you think so? What could go wrong?

Greetings,

  Hannes
