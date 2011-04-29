From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Fri, 29 Apr 2011 15:06:26 -0400
Message-ID: <20110429190626.GB22387@hmsreliant.think-freely.org>
References: <loom.20110427T140651-957@post.gmane.org>
 <20110427130114.GA1895@hmsreliant.think-freely.org>
 <loom.20110428T074300-379@post.gmane.org>
 <20110428110634.GA4165@hmsreliant.think-freely.org>
 <loom.20110429T103558-283@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ajit <ajitsa_bes@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51150 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933034Ab1D2TGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 15:06:48 -0400
Content-Disposition: inline
In-Reply-To: <loom.20110429T103558-283@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2011 at 08:39:31AM +0000, Ajit wrote:
> Neil Horman <nhorman <at> tuxdriver.com> writes:
> 
> 
> > > 
> > Can you just post a link to the code?
> > Neil
> > 
> > > Thank you. 
> > > 
> > > 
> 
> here are the links to the code..
> 
> sender code : http://pastebin.com/se17Xn96
> 
> The command line arguments are like ./pgm_name eth0 /root/abc
> 
> where abc is the file name.
> 
> receiver code : http://pastebin.com/AKiUWzwR
> 
> just run it.
> 
> In the receiver code I have assigned offset to buffer[15], it was just for
> debugging purpose. Actually offset must have 16 bits of buffer[15] and
> buffer[16], but for files of around 100kb-200kb it will easily work..no need to
> modify.
> 
> Thank you.
> 
Well, just looking at it, I presume you're getting an error on send when you
send over your raw socket.  If so, whats the error you're getting?  If you're
not getting an error, then you're dropping it somewhere in the stack.  After you
loose the data in question, what do youre /proc/net/dev and ethtool stats look
like?
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
