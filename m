From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] dev: use name hash for dev_seq_ops
Date: Fri, 21 Oct 2011 02:55:38 -0400 (EDT)
Message-ID: <20111021.025538.1690130663514126869.davem@redhat.com>
References: <1319097717-14910-1-git-send-email-mmaruseac@ixiacom.com>
	<1319179510-10715-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, mmaruseac@ixiacom.com
To: mihai.maruseac@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319179510-10715-1-git-send-email-mmaruseac@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mihai Maruseac <mihai.maruseac@gmail.com>
Date: Fri, 21 Oct 2011 09:45:10 +0300

> Instead of using the dev->next chain and trying to resync at each call to
> dev_seq_start, use the name hash, keeping the bucket and the offset in
> seq->private field.
> 
> Tests revealed the following results for ifconfig > /dev/null
 ...
> Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>

Applied.
