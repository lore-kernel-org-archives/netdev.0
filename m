From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sk98lin, jumbo frames, and memory fragmentation
Date: Mon, 1 Oct 2007 14:06:27 -0700
Message-ID: <20071001140627.1e2e665f@freepuppy.rosehill>
References: <47015A24.7000701@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux@syskonnect.de, netdev@vger.kernel.org
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48358 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752300AbXJAVG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 17:06:58 -0400
In-Reply-To: <47015A24.7000701@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 01 Oct 2007 14:35:48 -0600
"Chris Friesen" <cfriesen@nortel.com> wrote:

> 
> Hi all,
> 
> We're considering some hardware that uses the sk98lin network hardware, 
> and we'll be using jumbo frames.  Looking at the driver, when using a 
> 9KB MTU it seems like it would end up trying to atomically allocate a 
> 16KB buffer.
> 
> Has anyone heard of this been a problem?  It would seem like trying to 
> atomically allocate four physically contiguous pages could become tricky 
> after the system has been running for a while.
> 
> The reason I ask is that we ran into this with the e1000.  Before they 
> added the new jumbo frame code it was trying to atomically allocate 32KB 
> buffers and we would start getting allocation failures after a month or 
> so of uptime.
> 
> Any information anyone can provide would be appreciated.

Adding fragmentation support to skge driver is on my list of
possible extensions. sky2 driver already supports it (yet one
more feature that the vendor sk98lin driver doesn't do).

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
