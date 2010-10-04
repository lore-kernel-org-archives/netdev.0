From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] sctp: prevent reading out-of-bounds memory
Date: Sun, 03 Oct 2010 21:59:54 -0700 (PDT)
Message-ID: <20101003.215954.112586909.davem@davemloft.net>
References: <201010012116.o91LGwS5021150@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.j.rosenberg@gmail.com,
	vladislav.yasevich@hp.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44001
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751341Ab0JDE7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 00:59:33 -0400
In-Reply-To: <201010012116.o91LGwS5021150@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 01 Oct 2010 14:16:58 -0700

> From: Dan Rosenberg <dan.j.rosenberg@gmail.com>
> 
> Two user-controlled allocations in SCTP are subsequently dereferenced as
> sockaddr structs, without checking if the dereferenced struct members fall
> beyond the end of the allocated chunk.  There doesn't appear to be any
> information leakage here based on how these members are used and
> additional checking, but it's still worth fixing.
> 
> [akpm@linux-foundation.org: remove unfashionable newlines, fix gmail tab->space conversion]
> Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
