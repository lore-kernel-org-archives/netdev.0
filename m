From: David Miller <davem@davemloft.net>
Subject: Re: linked list corruption/use after free on bonding unload.
Date: Tue, 09 Apr 2013 15:38:31 -0400 (EDT)
Message-ID: <20130409.153831.1917719597139130549.davem@davemloft.net>
References: <20130409185002.GA3784@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934841Ab3DITid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 15:38:33 -0400
In-Reply-To: <20130409185002.GA3784@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 9 Apr 2013 14:50:02 -0400

> Just hit this while doing a load/unload test of various modules.
> No bonding configuration had been set up, just the module loaded.

What tree?

We recently had to revert a bonding "fix" and implement it differently.
So Linus's tree could cause this oops on bonding unload but 'net'
won't.
