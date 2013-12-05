From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] x25: convert printks to pr_<level>
Date: Wed, 04 Dec 2013 20:09:33 -0800
Message-ID: <1386216573.30493.86.camel@joe-AO722>
References: <529FEDBC.9030302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andrew.hendry@gmail.com,
	linux-x25@vger.kernel.org, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0106.hostedemail.com ([216.40.44.106]:60370 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752867Ab3LEEJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 23:09:38 -0500
In-Reply-To: <529FEDBC.9030302@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 11:06 +0800, Wang Weidong wrote:
> use pr_<level> instead of printk(LEVEL)

Consider adding
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
or
#define pr_fmt(fmt) "X25: " fmt
to each of these files before any #include
and removing the leading "X25: " in each of
the formats.
