From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/7] tcp: bugs and cleanup for 2.6.34-rc1
Date: Thu, 11 Mar 2010 10:14:11 -0800
Message-ID: <1268331251.17462.51.camel@Joe-Laptop.home>
References: <4B98D592.6040301@gmail.com>
	 <1268319664.2986.535.camel@edumazet-laptop>  <4B992A89.6040700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?Penttil=E4?= Mika <mika.penttila@ixonos.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1650 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933720Ab0CKSOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 13:14:20 -0500
In-Reply-To: <4B992A89.6040700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-03-11 at 12:38 -0500, William Allen Simpson wrote:
> > http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=28b2774a0d5852236dab77a4147b8b88548110f1

In that patch, it might be  better to use
	u16 s_data_desired = 0;
not
	int s_data_desired = 0;


