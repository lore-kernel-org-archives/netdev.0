From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: [PATCH v2 net-next 1/4] net: socket: add support for async operations
Date: Thu, 19 Mar 2015 10:43:16 -0700
Message-ID: <550B0AB4.2060507@intel.com>
References: <20150316161508.16418.23674.stgit@tstruk-mobl1> <20150316161514.16418.67336.stgit@tstruk-mobl1> <20150319162024.GO29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-aio@kvack.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ying.xue@windriver.com, bcrl@kvack.org,
	linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61022 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481AbbCSRpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 13:45:53 -0400
In-Reply-To: <20150319162024.GO29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2015 09:20 AM, Al Viro wrote:
> is completely pointless.  Just have sock_read_iter() and sock_write_iter()
> check if your new methods are present and use those if those are.
> 

Ok, that will work for me too.

> What's more, I'm not at all sure that you want to pass iocb that way -
> kernel-side msghdr isn't tied to userland one anymore, so we might as well
> stash a pointer to iocb into it.  Voila - no new methods needed at all.

Good point, so what do you prefer - to add iocd to msghdr or to call the new
methods from sock_read_iter() and sock_write_iter()?
Either way is good for me.
