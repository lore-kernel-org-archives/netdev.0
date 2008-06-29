From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: em_cmp.c use unaligned access helpers
Date: Mon, 30 Jun 2008 01:26:39 +0200
Message-ID: <20080629232638.GO20815@postel.suug.ch>
References: <1214428440.6908.1.camel@brick> <20080627.201649.95998057.davem@davemloft.net> <20080629095424.GM20815@postel.suug.ch> <1214762490.6037.9.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47113 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbYF2X0U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jun 2008 19:26:20 -0400
Content-Disposition: inline
In-Reply-To: <1214762490.6037.9.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Harvey Harrison <harvey.harrison@gmail.com> 2008-06-29 11:01
> OK, but be16/32_to_cpu is a no-op on be-arches, so there is a bug here on
> big-endian machines as they won't switch it back, your simplified patch
> is actually a bugfix in that case.

I noticed that my change wouldn't be correct. The point is to allow
userspace to convert the filter values to big endian once, supply them
to the kernel and compare big endian values directly. The be16/32_to_cpu
convertion is available to support greater-than/lesser-than on little
endian architectures.
