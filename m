From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] softirq: reduce latencies
Date: Thu, 03 Jan 2013 22:53:27 -0800
Message-ID: <1357282407.21409.28206.camel@edumazet-glaptop>
References: <1357216132.21409.24107.camel@edumazet-glaptop>
	 <20130103124608.136fd65b.akpm@linux-foundation.org>
	 <1357252875.21409.26390.camel@edumazet-glaptop>
	 <87r4m1r0hm.fsf@sejong.aot.lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Namhyung Kim <namhyung@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:42511 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab3ADGxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 01:53:31 -0500
In-Reply-To: <87r4m1r0hm.fsf@sejong.aot.lge.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 14:16 +0900, Namhyung Kim wrote:

> Probably a silly question:
> 
> Why not using ktime rather than jiffies for this?

ktime is too expensive on some hardware.

Here we only want a safety belt, no need for high time resolution.
