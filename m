From: George Nychis <gnychis@cmu.edu>
Subject: Re: [offlist] Re: [LARTC] how to do probabilistic packet loss in
 kernel?
Date: Wed, 19 Apr 2006 09:55:51 -0400
Message-ID: <44464167.40702@cmu.edu>
References: <4902.128.2.140.224.1145227461.squirrel@128.2.140.224> <Pine.LNX.4.61.0604161909310.6147@virgule.wonderfrog.net> <4442E319.50309@cmu.edu> <Pine.LNX.4.61.0604161933210.6147@virgule.wonderfrog.net> <2959.128.237.238.138.1145242426.squirrel@128.237.238.138> <Pine.LNX.4.61.0604190741260.6853@virgule.wonderfrog.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.andrew.cmu.edu ([128.2.10.81]:59521 "EHLO
	smtp.andrew.cmu.edu") by vger.kernel.org with ESMTP
	id S1750777AbWDSN4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 09:56:18 -0400
To: "Martin A. Brown" <martin@linux-ip.net>, lartc@mailman.ds9a.nl,
	netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.61.0604190741260.6853@virgule.wonderfrog.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Martin,

I was able to do it with netem and its working great now.

I've actually moved on to another challenge, I would like to drop 
packets at the hardware level such as to see rate control.

Because when netem drops a packet, TCP responds, however the lower level 
card will not interact because it never sees the loss.

What I want to do is somehow cause the card to send a corrupted packet 
based on a probability, or not send the packet but make it think that it 
did.

I'm using madwifi and I've found in the code where it does rate control 
and sends out the data, so i'm hoping to make this happen, but having 
troubles!

So if anyone else has any ideas on how to get rate control interactive 
packet loss, i'd love it.

- George


Martin A. Brown wrote:
> Hello George,
> 
> Unfortunately, I cannot answer your most recent question.  I'm 
> hoping that Stephen Hemminger can answer your question.  He is 
> subscribed to the LARTC list, is also the author of netem and 
> seems to be a smart cookie.
> 
> Good luck,
> 
> -Martin
> 
