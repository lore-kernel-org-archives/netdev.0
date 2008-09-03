From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 3 Sep 2008 17:27:34 +0400
Message-ID: <20080903132734.GA17541@2ka.mipt.ru>
References: <20080902194603.GA2825@2ka.mipt.ru> <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com> <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com> <20080903.040626.198546183.davem@davemloft.net> <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:54737 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529AbYICN2C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 09:28:02 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Wed, Sep 03, 2008 at 03:05:07PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> TCP socket, transferring 20Mbytes file (located in initramfs) in loop
> with sendfile() : 5.7Mbytes/s

And _THIS_ is a serious problem. Let's assume that sendfile is broken or
driver/hardware does not support scatter/gather and checksumming (does it?).
Can you saturate the link with pktgen (1) and usual tcp socket (2).
Assuming second case will fail, does it also broken because of very
small performance of the copy from the userspace?

-- 
	Evgeniy Polyakov
