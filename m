From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: net: Remove iocb argument from sendmsg and recvmsg
Date: Wed, 11 Mar 2015 09:09:27 -0700
Message-ID: <550068B7.8080403@intel.com>
References: <54FFAA5B.3080608@intel.com> <20150311.000248.417529352060472113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, herbert@gondor.apana.org.au, hch@lst.de,
	viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18041 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755AbbCKQL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 12:11:59 -0400
In-Reply-To: <20150311.000248.417529352060472113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2015 09:02 PM, David Miller wrote:
> 
> Because of the way you quoted the patch, it looked like a list posting
> looping back to the list again, because of the "List-ID: " email header.
> 
> Therefore your posting was blocked and you'll have to resend your posting
> in a way such that this doesn't happen.
> 
Oops, sorry, here it is.

Hi,
After couple of attempts to implement an user space interface to crypto HW that would meet our performance requirements, and after discussion with Herbert, we have come to conclusion that using AF_ALG sockets and AIO interface is the way to go.
Unfortunately it looks like AIO operations will no longer be supported on sockets because of the commit 1b784140474e4fc94281a49e96c67d29df0efbde.
My question is why do we want to abandon AIO support in the socket layer? Is it not worth keeping it for scenarios like this?
Do we have any alternative?
Here is the mentioned patch.

https://patchwork.kernel.org/patch/5971491/

Regards,
Tadeusz
