From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] mwifiex: Remove casting the return value which is a
 void pointer
Date: Sun, 08 Sep 2013 22:41:03 -0700
Message-ID: <1378705263.1928.7.camel@joe-AO722>
References: <004d01cead1d$3058dcf0$910a96d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'John W. Linville'" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	'David Miller' <davem@davemloft.net>,
	'Bing Zhao' <bzhao@marvell.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0054.hostedemail.com ([216.40.44.54]:57550 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751075Ab3IIFvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 01:51:32 -0400
In-Reply-To: <004d01cead1d$3058dcf0$910a96d0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-09 at 14:26 +0900, Jingoo Han wrote:
> Casting the return value which is a void pointer is redundant.
> The conversion from void pointer to any other pointer type is
> guaranteed by the C programming language.

spatch (aka: Coccinelle) should be able to find a lot
of these with:

$ cat void.cocci 
@@
void *t;
type other;
@@

-	(other *)t
+	t
