From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Mon, 9 Apr 2007 16:08:22 -0400
Message-ID: <200704091608.23270.rgetz@blackfin.uclinux.org>
References: <6d6a94c50704082001y5c13c865ic3d70217aba7d181@mail.gmail.com> <20070409.095523.122833625.davem@davemloft.net> <20070409.114323.78734391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, alan@lxorguk.ukuu.org.uk,
	waltje@uwalt.nl.mugnet.org, aubreylee@gmail.com,
	netdev@vger.kernel.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org, "David Howells" <dhowells@redhat.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:3705 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965396AbXDIUGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 16:06:49 -0400
In-Reply-To: <20070409.114323.78734391.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 9 Apr 2007 14:43, David Miller pondered:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 09 Apr 2007 09:55:23 -0700 (PDT)
> >
> > I will apply this patch.
>
> Actually I won't, the other comments in this thread make a lot
> of sense, we should try to make it build and work just as we
> do for other similar things on no-MMU.

Great. Any pointers in the right direction to remove the requirement of 
vm_insert_page() in the noMMU case?

Thanks
-Robin
