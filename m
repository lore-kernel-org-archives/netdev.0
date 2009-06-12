From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Thu, 11 Jun 2009 20:38:43 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0906112022000.31536@xanadu.home>
References: <alpine.LFD.2.00.0906111452340.31536@xanadu.home>
 <1244748719.2785.72.camel@achroite>
 <alpine.LFD.2.00.0906111605060.31536@xanadu.home>
 <20090611.171533.77414647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: bhutchings@solarflare.com, mfuzzey@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:32129 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbZFLAjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:39:02 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR003.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KL300GJYOGKNS20@VL-MO-MR003.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 11 Jun 2009 20:38:44 -0400 (EDT)
In-reply-to: <20090611.171533.77414647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2009, David Miller wrote:

> From: Nicolas Pitre <nico@cam.org>
> Date: Thu, 11 Jun 2009 16:24:05 -0400 (EDT)
> 
> > Your shortsightedness and refusal for accommodation about needs 
> > that aren't yours is representative of the main reason why there is 
> > still a disconnect between mainline people and embedded people.
> 
> Our main beef with the embedded folks is short-sightedness and a
> desire for quick solutions rather than clean ones with long term
> considerations in mind.

Let me quote Martin again:

| If your view prevails all I will have achieved is the replacement of 
| my personel 2 line #ifdef hack by 500 lines of "generic" code that no 
| one else will ever see. Of course in the grand scheme of things that's
| insignificant but then I hope people don't complain about embedded
| developpers not contributing enough. I did try, really.

Wasn't his patch looking like a clean solution with long term 
considerations?  If no then I don't think we have much else left to 
discuss.

And no, as absurd and strange that might sound to you, maintaining extra 
components to access the ethtool interface from user space (whether or 
not it is for broken PHY or whatnot) in an embedded product is often not 
worth the bother.  Those systems are not workstations where all that you 
have to do is fire an editor and type one line of command in a script 
because the default environment makes everything already available.  

Compare that to the quick solution that the one line hack represents.


Nicolas
