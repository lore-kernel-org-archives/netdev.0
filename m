From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCHSET] more iov_iter conversion in net/*
Date: Sun, 01 Feb 2015 22:26:46 -0800 (PST)
Message-ID: <20150201.222646.1280320067605385223.davem@davemloft.net>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623AbbBBG0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 01:26:47 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 31 Jan 2015 03:55:13 +0000

> 	->sendmsg() side of that business, now.  By the end of it, we
> get all ->sendmsg() instances leaving iovec unchanged and ->msg_iter -
> drained.
 ...
> 	The pile after that one will be dealing with the kernel_sendmsg and
> kernel_recvmg callers - at that point we can start reaping benefits of
> consistent way ->msg_iter is handled.  Note that after these changes if
> iov_iter_kvec() is used to initialize ->msg_iter, we don't need the games
> with get_fs()/set_fs() anymore; just sock_sendmsg()/sock_recvmsg() will do,
> so quite a few of those kernel_{send,recv}msg() callers will turn into
> sock_{send,recv}msg() ones.

The content of this series looks fine, but I really would like you
to put proper "subsystem: " prefixes into the commit log header
lines of these commits.

Patch 2 and 3 should use "ipv6: ", patch #4 should use whatever the
name of that device driver "vmw_vmci: " or similar, etc.

Thanks.
