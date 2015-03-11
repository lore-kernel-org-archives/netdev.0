From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: net: Remove iocb argument from sendmsg and recvmsg
Date: Tue, 10 Mar 2015 20:25:29 -0700
Message-ID: <54FFB5A9.5030008@intel.com>
References: <54FFAA5B.3080608@intel.com> <54FFB3E9.50905@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, Al Viro <viro@ZenIV.linux.org.uk>,
	netdev@vger.kernel.org,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Ying Xue <ying.xue@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2346 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752872AbbCKD2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 23:28:01 -0400
In-Reply-To: <54FFB3E9.50905@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2015 08:18 PM, Ying Xue wrote:
> Sorry, I did not realize the case when I created the commit. However, although I
> don't understand its scenario, in my opinion, adding one redundant argument for
> all sockets to satisfy the special case seems unreasonable for us.

In my opinion this is not about a single, special case, but rather about being able to support asynchronous operations on socket interface.
It is important for AF_ALG since we have crypto HW accelerators, that people want to access from user space, but in the future there might be other use cases.
Regards,
Tadeusz
