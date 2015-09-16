From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2] net: Initialize table in fib result
Date: Wed, 16 Sep 2015 16:58:51 -0700
Message-ID: <55FA023B.50601@gmail.com>
References: <1442420199-51715-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: sergey.senozhatsky.work@gmail.com, richard.alpe@ericsson.com,
	festevam@gmail.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34284 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbbIQACe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 20:02:34 -0400
Received: by padhy16 with SMTP id hy16so2459440pad.1
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 17:02:34 -0700 (PDT)
In-Reply-To: <1442420199-51715-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/15 09:16, David Ahern wrote:
> The root cause is use of res.table uninitialized.
> 
> Thanks to Nikolay for noticing the uninitialized use amongst the maze of
> gotos.
> 
> As Nikolay pointed out the second initialization is not required to fix
> the oops, but rather to fix a related problem where a valid lookup should
> be invalidated before creating the rth entry.
> 
> Fixes: b7503e0cdb5d ("net: Add FIB table id to rtable")
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> Reported-by: Richard Alpe <richard.alpe@ericsson.com>
> Reported-by: Fabio Estevam <festevam@gmail.com>
> Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

There are enough Tested-by tags, but thanks for fixing this!
-- 
Florian
