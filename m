From: Ying Xue <ying.xue@windriver.com>
Subject: Re: net: Remove iocb argument from sendmsg and recvmsg
Date: Wed, 11 Mar 2015 11:18:01 +0800
Message-ID: <54FFB3E9.50905@windriver.com>
References: <54FFAA5B.3080608@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, Al Viro <viro@ZenIV.linux.org.uk>,
	<netdev@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Tadeusz Struk <tadeusz.struk@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60719 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbbCKDTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 23:19:41 -0400
In-Reply-To: <54FFAA5B.3080608@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I did not realize the case when I created the commit. However, although I
don't understand its scenario, in my opinion, adding one redundant argument for
all sockets to satisfy the special case seems unreasonable for us.

Regards,
Ying

On 03/11/2015 10:37 AM, Tadeusz Struk wrote:
> Hi,
> After couple of attempts to implement an user space interface to crypto HW that would meet our performance requirements, and after discussion with Herbert, we have come to conclusion that using AF_ALG sockets and AIO interface is the way to go.
> Unfortunately it looks like AIO operations will no longer be supported on sockets because of the commit 1b784140474e4fc94281a49e96c67d29df0efbde.
> My question is why do we want to abandon AIO support in the socket layer? Is it not worth keeping it for scenarios like this?
> Do we have any alternative?
> The mentioned patch attached for your reference.
> Regards,
> Tadeusz
> 
