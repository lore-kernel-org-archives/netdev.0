From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [2.6 patch] __inet6_csk_dst_store(): fix check-after-use
Date: Mon, 15 Oct 2007 11:45:10 +0900
Message-ID: <20071015113723.00F7.NAKAM@linux-ipv6.org>
References: <20071014175212.GP4211@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:47144 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755199AbXJODET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Oct 2007 23:04:19 -0400
In-Reply-To: <20071014175212.GP4211@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sun, 14 Oct 2007 19:52:12 +0200
Adrian Bunk <bunk@kernel.org> wrote:

> The Coverity checker spotted that we have already oops'ed if "dst"
> was NULL.
> 
> Since "dst" being NULL doesn't seem to be possible at this point this 
> patch removes the NULL check.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Agreed.

Acked-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

-- 
Masahide NAKAMURA

