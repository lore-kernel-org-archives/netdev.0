From: David Miller <davem@davemloft.net>
Subject: Re: A pure virtual nic
Date: Tue, 03 Jan 2012 21:48:24 -0500 (EST)
Message-ID: <20120103.214824.1395410287552500660.davem@davemloft.net>
References: <CAEk7JKY6xtBm4DraqRMYEnmZZhsOZoZG-MSgrq+W4n2eCCz1Sg@mail.gmail.com>
	<4EFDDC55.80406@candelatech.com>
	<CAEk7JKa-H=7oHjU-A1z8aNUZxd3TkJpBmwwrp4zWmZ_i2SQ+Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, mirqus@gmail.com, netdev@vger.kernel.org
To: lizhenhua.dev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab2ADCsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 21:48:30 -0500
In-Reply-To: <CAEk7JKa-H=7oHjU-A1z8aNUZxd3TkJpBmwwrp4zWmZ_i2SQ+Tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Li, Zhen-Hua" <lizhenhua.dev@gmail.com>
Date: Wed, 4 Jan 2012 10:07:08 +0800

> When a program sends out a packet, at start_xmit function. it will
> unpack it and packet again with HTTP proxy headers, then give it to
> the actual physical ethernet adapter.
> When it receives a packet, unpack it and remove the http proxy
> headers, and then put it back to the queue in kernel.

A netfilter module is a much more appropriate way to implement this.
You can even implement this kind of packet mangling in userspace using
nfqueue.
