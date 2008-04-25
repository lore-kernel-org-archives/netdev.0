From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] tcp_probe buffer overflow and incorrect return
 value
Date: Thu, 24 Apr 2008 21:12:35 -0700 (PDT)
Message-ID: <20080424.211235.08123917.davem@davemloft.net>
References: <4810FDB6.2060805@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: virtualphtn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36914
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750901AbYDYEMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 00:12:40 -0400
In-Reply-To: <4810FDB6.2060805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Quetchenbach <virtualphtn@gmail.com>
Date: Thu, 24 Apr 2008 14:37:58 -0700

> tcp_probe has a bounds-checking bug that causes many programs (less, python) to
> crash reading /proc/net/tcp_probe. When it outputs a log line to the reader, it
> only checks if that line alone will fit in the reader's buffer, rather than that
> line and all the previous lines it has already written.
> 
> tcpprobe_read also returns the wrong value if copy_to_user fails--it just passes
> on the return value of copy_to_user (number of bytes not copied), which makes a
> failure look like a success.
> 
> This patch fixes the buffer overflow and sets the return value to -EFAULT if
> copy_to_user fails.
> 
> Patch is against latest net-2.6; tested briefly and seems to fix the crashes in
> less and python.
> 
> Signed-off-by: Tom Quetchenbach <virtualphtn@gmail.com>

Thanks a lot for fixing this bug.

I've applied this patch and I'll queue it up for -stable too.

Thanks again.
