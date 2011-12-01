From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 net-next 2/2] netem: add cell concept to simulate
 special MAC behavior
Date: Thu, 1 Dec 2011 08:57:01 -0800
Message-ID: <20111201085701.02f885c5@nehalam.linuxnetplumber.net>
References: <20111201082436.20f21e52@nehalam.linuxnetplumber.net>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AEFA@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Hagen Paul Pfeifer" <hagen@jauu.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47054 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755407Ab1LAQ5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 11:57:05 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AEFA@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Dec 2011 16:38:51 -0000
"David Laight" <David.Laight@ACULAB.COM> wrote:

>  
> > One idea to do small delays at higher speed is to insert 
> > dummy pad frames into the device.
> > It would mean generating garbage, but would allow for
> > highly accurate fine grain delay.
> 
> Not a good idea.
> They would have to be sent to a known MAC address
> otherwise all the ethernet switches would forward them
> on all output ports.
> 
> 	David
> 
> 

Yes it would have to be a constant destination, not sure if there
is a discard value in Ethernet protocol spec.
