From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] cxgb4: add dcb info node in debugfs
Date: Tue, 22 Dec 2015 15:45:52 -0500 (EST)
Message-ID: <20151222.154552.1762036210080562354.davem@davemloft.net>
References: <1450682170-7106-1-git-send-email-hariprasad@chelsio.com>
	<1450682170-7106-4-git-send-email-hariprasad@chelsio.com>
	<CAJ3xEMjctGauyRjCKLV+wACkzDC5xF8J9khdhCm+YZXuEafU5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org, leedom@chelsio.com,
	nirranjan@chelsio.com, john.r.fastabend@intel.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626AbbLVUpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 15:45:54 -0500
In-Reply-To: <CAJ3xEMjctGauyRjCKLV+wACkzDC5xF8J9khdhCm+YZXuEafU5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Mon, 21 Dec 2015 09:33:22 +0200

> On Mon, Dec 21, 2015 at 9:16 AM, Hariprasad Shenai
> <hariprasad@chelsio.com> wrote:
>> Add new /sys/kernel/debug/cxgb4/*/dcb_info node to dump out
>> various Data Center Bridging information.
> 
> why? what's wrong with using the lldp tool for that purpose?

Agreed, and I don't like your explanation.

Even if you are using firmware managed DCB, the lldp tool should be
usable for querying.

People need to stop putting so much crap into debugfs, it's a serious
pet peeve of mine.

Every piece of driver unique interface crap you put into debugfs is a
_HARDSHIP_ for the user.  Because they have to learn a unique way to
do X in every driver that tries to export the same kind of
functionality.
