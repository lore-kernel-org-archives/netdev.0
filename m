From: David Miller <davem@davemloft.net>
Subject: Re: net: Remove iocb argument from sendmsg and recvmsg
Date: Wed, 11 Mar 2015 00:06:59 -0400 (EDT)
Message-ID: <20150311.000659.1763019676805929532.davem@davemloft.net>
References: <54FFAA5B.3080608@intel.com>
	<54FFB3E9.50905@windriver.com>
	<54FFB5A9.5030008@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, herbert@gondor.apana.org.au, hch@lst.de,
	viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: tadeusz.struk@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbbCKEHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 00:07:01 -0400
In-Reply-To: <54FFB5A9.5030008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tadeusz Struk <tadeusz.struk@intel.com>
Date: Tue, 10 Mar 2015 20:25:29 -0700

> In my opinion this is not about a single, special case, but rather
> about being able to support asynchronous operations on socket
> interface.

Nobody used the socket AIO facility for two decades, it just
rotted and turned out to be buggy and reference freed stack
memory on top of that.

I am absolutely not convinced this is the only way to solve your
problem.
