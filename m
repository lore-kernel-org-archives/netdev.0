From: David Miller <davem@davemloft.net>
Subject: Re: [v3] UCC_GETH/UCC_FAST: Use IS_ERR_VALUE_U32 API to avoid
 IS_ERR_VALUE abuses.
Date: Mon, 25 Jul 2016 17:48:26 -0700 (PDT)
Message-ID: <20160725.174826.2146830871661675561.davem@davemloft.net>
References: <1469297151-9763-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, leoli@freescale.com, qiang.zhao@freescale.com,
	scottwood@freescale.com, viresh.kumar@linaro.org,
	akpm@linux-foundation.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux@roeck-us.net, arnd@arndb.de
To: arvind.yadav.cs@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbcGZAs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 20:48:28 -0400
In-Reply-To: <1469297151-9763-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Sat, 23 Jul 2016 23:35:51 +0530

> However, anything that passes an 'unsigned short' or 'unsigned int'
> argument into IS_ERR_VALUE() is guaranteed to be broken, as are
> 8-bit integers and types that are wider than 'unsigned long'.
 ...
> Passing value in IS_ERR_VALUE() is wrong, as they pass an
> 'unsigned int' into a function that takes an 'unsigned long'
> argument.This happens to work because the type is sign-extended
> on 64-bit architectures before it gets converted into an
> unsigned type.

This commit log message is a complete mess, you're saying exactly
the same thing over and over again.

Also your Subject line is not formatted correctly, do not list
the subsystem prefix in ALL CAPS.  Just plain "ucc_geth/ucc_fast: "
would be fine.
