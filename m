From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v5 3/5 RFC] TCPCT part1c: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS, functions
Date: Tue, 10 Nov 2009 07:31:37 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911100706120.7059@melkinpaasi.cs.helsinki.fi>
References: <4AF83E2D.1050401@gmail.com> <4AF84458.9070000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56760 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbZKJFbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 00:31:33 -0500
In-Reply-To: <4AF84458.9070000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 Nov 2009, William Allen Simpson wrote:

> Define sysctl (tcp_cookie_size) to turn on and off the cookie option
> default globally, instead of a compiled configuration option.
> 
> Define per socket option (TCP_COOKIE_TRANSACTIONS) for setting constant
> data values, retrieving variable cookie values, and other facilities.

I guess most of the cookie stuff have nothing to do with the next, 
please make them separate:

> Redefine two TCP header functions to accept TCP header pointer.
> When subtracting, return signed int to allow error checking.

Convert the users here, not in the fifth patch to avoid noise in the large 
fifth patch.

And, I read more that fifth patch... seriously, please consider now to 
apply _all_ the coding style changes that have been brought to your 
attention by multiple people (you should know them now but for some reason 
again you choose to resent without complying -- I guess on purpose) into 
all upcoming patches you submit.

-- 
 i.
