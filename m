From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] cls_cgroup: fix an oops when removing a cgroup
Date: Mon, 5 Jan 2009 17:10:58 +0100
Message-ID: <20090105161058.GM20815@postel.suug.ch>
References: <49584A9F.40202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52858 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbZAEQKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 11:10:39 -0500
Content-Disposition: inline
In-Reply-To: <49584A9F.40202@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Li Zefan <lizf@cn.fujitsu.com> 2008-12-29 11:57
> When removing a cgroup, an oops was triggered immediately. The cause
> is wrong kfree() in cgrp_destroy().

Good catch.

Acked-by: Thomas Graf <tgraf@suug.ch>
