From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET]: Remove FASTCALL/fastcall macros
Date: Sun, 16 Dec 2007 20:30:29 -0800 (PST)
Message-ID: <20071216.203029.255544808.davem@davemloft.net>
References: <1197864985.3749.117.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53366
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751736AbXLQEac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 23:30:32 -0500
In-Reply-To: <1197864985.3749.117.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Sun, 16 Dec 2007 20:16:25 -0800

> X86_32 was the last user of the FASTCALL/fastcall macros, now that it
> uses regparm(3) by default, these macros expand to nothing.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> Dave, this is a wrap-up of my patch in your net-2.6.25.git with
> the build breakage fix from Andrew Morton included.  This also
> chops the fastcall macro which is also now empty.

If only it applied:

davem@sunset:~/src/GIT/net-2.6.25$ pcheck diff
+ git apply --check --whitespace=error-all diff
error: patch failed: drivers/net/ns83820.c:611
error: drivers/net/ns83820.c: patch does not apply
error: patch failed: include/net/bluetooth/rfcomm.h:252
error: include/net/bluetooth/rfcomm.h: patch does not apply
error: patch failed: include/net/sock.h:774
error: include/net/sock.h: patch does not apply
