From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3 v2] ipv6: rename ADBG() to pr_xxx()
Date: Tue, 13 Aug 2013 09:48:54 -0700
Message-ID: <1376412534.1949.33.camel@joe-AO722>
References: <5209E6E8.1030702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:58383 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757387Ab3HMQsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 12:48:55 -0400
In-Reply-To: <5209E6E8.1030702@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-13 at 15:57 +0800, Ding Tianhong wrote:
> According to Joe Perches opinions, the ADBG() was tedious and it is
> better to remove the KERN_<LEVEL>s and use the pr_xxx() instead of ADBG().

No, that's not really what I wrote.

I suggested it might be better to remove the KERN_<LEVELS>
from these ADBG uses and use pr_debug.

As is, you've changed logging messages which today
always compile away to nothing to now emit what I
think are pretty unnecessary messages.
