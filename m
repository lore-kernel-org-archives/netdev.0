From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH]ipv6:fix an oops when force unload ipv6 module
Date: Wed, 16 Dec 2009 21:51:35 -0800
Message-ID: <20091216215135.37d89adc@nehalam>
References: <4B29BECD.1040004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	yoshfuji@linux-ipv6.org
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34296 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbZLQFwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 00:52:08 -0500
In-Reply-To: <4B29BECD.1040004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Dec 2009 13:17:01 +0800
Yang Hongyang <yanghy@cn.fujitsu.com> wrote:

> When I do an ipv6 module force unload,I got the following oops:
> #rmmod -f ipv6
>

Okay, but force unloading IPV6 leaves some dangling control
sockets that will crash in other ways.
