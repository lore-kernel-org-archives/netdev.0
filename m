From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] Removing lots of IS_ERR_VALUE abuses and compilation warning.
Date: Thu, 07 Jul 2016 17:45:53 +0200
Message-ID: <3262228.FZLtnpegJr@wuerfel>
References: <1467904336-3588-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>, leoli@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:55287 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077AbcGGPml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 11:42:41 -0400
In-Reply-To: <1467904336-3588-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, July 7, 2016 8:42:16 PM CEST Arvind Yadav wrote:
>     Passing value in IS_ERR_VALUE() is wrong, as they
>     pass an 'int' into a function that takes an 'unsigned long'
>     argument. This happens to work because the type is sign-extended
>     on 64-bit architectures before it gets converted into an
>     unsigned type.
> 
>     Passing an 'unsigned short' or 'unsigned int'
>     argument into IS_ERR_VALUE() is guaranteed to be broken, as are
>     8-bit integers and types that are wider than 'unsigned long'.
> 
>     Any user will get compilation warning for that do not pass an
>     'unsigned long' argument.
> 
>     Commit '287980e49f; - This change is alreday fixes lots of other
>     worst abusers.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>

just notice about your submission that the changelog is whitespace
damaged, you probably got the leading whitespace when you pasted
a git log into the commit.

	Arnd
