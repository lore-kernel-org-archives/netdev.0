From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] Add explicit bound checks in net/socket.c
Date: Mon, 28 Sep 2009 12:57:57 -0700 (PDT)
Message-ID: <20090928.125757.151682793.davem@davemloft.net>
References: <20090926205432.24aa1023@infradead.org>
	<20090926190103.GB4356@lenovo>
	<20090926212302.0ce64a5c@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, mingo@elte.hu,
	netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752993AbZI1T5j@vger.kernel.org>
In-Reply-To: <20090926212302.0ce64a5c@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@infradead.org>
Date: Sat, 26 Sep 2009 21:23:02 +0200

> The sys_socketcall() function has a very clever system for the copy
> size of its arguments. Unfortunately, gcc cannot deal with this in
> terms of proving that the copy_from_user() is then always in bounds.
> This is the last (well 9th of this series, but last in the kernel) such
> case around.
> 
> With this patch, we can turn on code to make having the boundary provably
> right for the whole kernel, and detect introduction of new security
> accidents of this type early on.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

Applied, thanks.
