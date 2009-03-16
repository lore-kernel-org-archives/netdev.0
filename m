From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Mon, 16 Mar 2009 13:43:13 +1030
Message-ID: <200903161343.13894.rusty@rustcorp.com.au>
References: <200903131017.11572.rusty@rustcorp.com.au> <200903141049.43202.rusty@rustcorp.com.au> <20090315.195806.97939686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: pktoss@gmail.com, dcbw@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41758 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbZCPDNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 23:13:21 -0400
In-Reply-To: <20090315.195806.97939686.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 16 March 2009 13:28:06 David Miller wrote:
> > Or should all devices which can't detect carrier set it to on, so
> > older NetworkManagers work?
> 
> It is my opinion that this is the only correct behavior.
> 
> If you don't know, it's on.  Because "on" means "usable".  And you
> can't fault NetworkManager or any other tool for making that kind of
> decision.

Yes, I agree that NM has to assume unknown == on.  But I still think the
kernel is right as it is to return -EOPNOTSUPP and let userspace deal with it.

"Let's fix broken userspace in the kernel" arguments make me nervous ;)

Cheers,
Rusty.
