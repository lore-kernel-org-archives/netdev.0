From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] Fix hang on IBM Token Ring PCMCIA card ejection
Date: Tue, 08 May 2007 01:19:31 -0400
Message-ID: <46400863.7010003@garzik.org>
References: <Pine.LNX.4.64.0703272255460.21789@utopia.booyaka.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mikep@linuxtr.net, netdev@vger.kernel.org, linux-tr@linuxtr.net
To: Paul Walmsley <paul@booyaka.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54386 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967902AbXEHFTe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:19:34 -0400
In-Reply-To: <Pine.LNX.4.64.0703272255460.21789@utopia.booyaka.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Walmsley wrote:
> From: Paul Walmsley <paul@booyaka.com>
> 
> Ejecting a PCMCIA IBM Token Ring card that has not had its dev->open()
> called will reliably trigger an uninitialized spinlock oops when
> spinlock debugging is enabled. The system then hangs, occasionally
> softlockup oopsing.  It seems that ibmtr.c:tok_interrupt() doesn't
> expect to be called before tok_open() is called, but tok_interrupt()
> gets called anyway when the card is ejected.  So, set an already-extant
> flag which causes tok_interrupt() to bail out early upon card ejection.
> Tested by inserting and removing the PCMCIA card several times.
> 
> Applies against 2.6.21-rc5.
> 
> 
> Signed-off-by: Paul Walmsley <paul@booyaka.com>

ACK but does not apply


