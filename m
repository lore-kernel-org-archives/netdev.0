From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Wed, 27 Apr 2011 09:01:14 -0400
Message-ID: <20110427130114.GA1895@hmsreliant.think-freely.org>
References: <loom.20110427T140651-957@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ajit <ajitsa_bes@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55259 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757893Ab1D0NB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 09:01:26 -0400
Content-Disposition: inline
In-Reply-To: <loom.20110427T140651-957@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2011 at 12:11:35PM +0000, Ajit wrote:
> Guys,
> 
> I have developed a code which uses raw sockets to transfer files. My code skips
> all the upper layer protocols,I have designed a small protocol of my own.
> 
> Now to problem is, whenever I transfer a large file it creates a problem. If
> transfer a file of suppose 100kb or more, only 97.9 Kb is received, unlike in
> the case of files smaller that 97.9.
> 
> What can be the problem ?? Does continuously sending and receiving of frames
> creates a problem ??
> 
> If any one is interested I can give you my code..
> 
> Thank you. 
> 
What transport layer are you using (UDP/TCP/SCTP/etc)?  Does a simmilar transfer
work if you use an actual TCP/UDP socket, rather than your raw one?  If you're
consistently getting 97.9k transferred, that almost sounds like some sort of
firewall type connection limitation.  Take a TCPDump from the peer to get a
better idea of whats going on when the connection fails
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
