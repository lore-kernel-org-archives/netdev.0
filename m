From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Thu, 28 Apr 2011 07:06:34 -0400
Message-ID: <20110428110634.GA4165@hmsreliant.think-freely.org>
References: <loom.20110427T140651-957@post.gmane.org>
 <20110427130114.GA1895@hmsreliant.think-freely.org>
 <loom.20110428T074300-379@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ajit <ajitsa_bes@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43419 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480Ab1D1LG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 07:06:56 -0400
Content-Disposition: inline
In-Reply-To: <loom.20110428T074300-379@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2011 at 05:49:23AM +0000, Ajit wrote:
> Neil Horman <nhorman <at> tuxdriver.com> writes:
> 
> 
> hii Neil,
> 
> I am not using the transport layer neither the Network layer. I have written a
> small protocol which work of a LAN without a router. So ideally there is no need
> of the network layer (I am using physical address for the transfer). 
> 
You may not be using the trasport layer, but you are still using IP, if you're
using SOCK_RAW sockets as you indicated.
> I have defined a filed called as "offset" and another one called as "id".
> Whenever you send a file, it is divided into various frames depending upon the
> size of the file and send with the same "id" and an offset incremented by 1.
> 
> As you said the firewall issues. I don't think that is the problem because I am
> sending the file to myself, but , on eth0 rather than lo, because send on lo
> wont give the expected results.
> 
Why not?

> If you still want some explanation then please ask me.
> 
Can you just post a link to the code?
Neil

> Thank you. 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
