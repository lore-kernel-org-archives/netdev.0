From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] include/linux/skbuff.h: using '0xffff' instead of '~0U'
Date: Sat, 1 Jun 2013 00:05:07 +0300
Message-ID: <CAHp75VfWvXkaoYQ_40idSsLYUA=YqaswnV2y-hODHjt7JMHQvQ@mail.gmail.com>
References: <51A6EBC5.7040601@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: edumazet@google.com, Pravin Shelar <pshelar@nicira.com>,
	mgorman@suse.de, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33913 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294Ab3EaVFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 17:05:08 -0400
In-Reply-To: <51A6EBC5.7040601@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 9:03 AM, Chen Gang <gang.chen@asianux.com> wrote:
>
> Both 'transport_header' and 'mac_header' are u16, which are never equal
> to '~0U'.
>
> So need use '0xffff' instead of '~0U'.

Why not "(u16)~0" ?
Or even better "!= USHORT_MAX"?

Or mac_header + 1 == 0, though it less clear.

--
With Best Regards,
Andy Shevchenko
