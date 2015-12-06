From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] sctp: packet timestamp fixes
Date: Sat, 05 Dec 2015 22:24:00 -0500 (EST)
Message-ID: <20151205.222400.709085792565221050.davem@davemloft.net>
References: <20151203184316.GF4164@mrl.redhat.com>
	<cover.1449249050.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	eric.dumazet@gmail.com, syzkaller@googlegroups.com,
	linux-sctp@vger.kernel.org, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, maze@google.com, dvyukov@google.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbLFDYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 22:24:06 -0500
In-Reply-To: <cover.1449249050.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri,  4 Dec 2015 15:14:02 -0200

> These a couple of fixes regarding sctp/packet timestamps.
> 
> Dmitry Vyukov <dvyukov@google.com> reported the counter leak on missing
> net_enable_timestamp() (2nd patch) and further testing here revealed the
> other two issues.
> 
> Please consider these to -stable.

Thanks for this, applied and queued up for -stable.
