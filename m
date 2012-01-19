From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] using NLM_F_DUMP flag constant in libnetlink.c
Date: Thu, 19 Jan 2012 14:17:20 -0800
Message-ID: <20120119141720.09bad41d@nehalam.linuxnetplumber.net>
References: <20120119.203108.460927494189100272.yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54086 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753927Ab2ASWRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 17:17:23 -0500
In-Reply-To: <20120119.203108.460927494189100272.yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2012 20:31:08 +0900 (JST)
Masatake YAMATO <yamato@redhat.com> wrote:

> This is trivial patch for libnetlink.c in iproute2.
> 
> In iproute2/include/linux/netlink.h NLM_F_DUMP is defines as:
> 
>    #define NLM_F_DUMP	(NLM_F_ROOT|NLM_F_MATCH)
> 
> It is not used in libnetlink.c. If used, the code becomes a bit easier
> to read.
> 
> 
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

Applied, thanks.
