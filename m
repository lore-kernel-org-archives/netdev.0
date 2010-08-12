From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Thu, 12 Aug 2010 14:10:02 -0400
Message-ID: <20100812141002.5f15c357@s6510>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, jordan_hargrave@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49382 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145Ab0HLSKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 14:10:13 -0400
In-Reply-To: <20100812173537.GA29784@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Aug 2010 12:35:37 -0500
Narendra K <Narendra_K@dell.com> wrote:

> +ifeq ($(shell test -L /usr/local/lib/libnetdevname.so; echo $$?),0)
> +LDLIBS +=-lnetdevname
> +DEFINES += -DLIBNETDEVNAME_PRESENT
> +endif

I assume any user or distro using libnetdevname will put it in
the standard path not /usr/lib, don't hard code the path here.

why not build a sample program like the ATM checks?
