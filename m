From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: ARP Spoofing
Date: Wed, 2 May 2007 17:16:19 -0700
Message-ID: <20070502171619.020a4def@freekitty>
References: <4638CDED.4020100@cs.byu.edu>
	<4638DEB9.90608@hp.com>
	<4638F6E8.3060609@nortel.com>
	<46392281.8040909@cs.byu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org
To: Topher Fischer <javert42@cs.byu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44809 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767281AbXECAQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 20:16:46 -0400
In-Reply-To: <46392281.8040909@cs.byu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 02 May 2007 17:45:05 -0600
Topher Fischer <javert42@cs.byu.edu> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Chris Friesen wrote:
> > Vlad Yasevich wrote:
> > 
> >> If by arp spoofing you mean receiving arp replies from multiple
> >> sources and
> >> trusting all of them, then I haven't seen anything.
> >>
> >> I don't know the history as to why nothing has has been done.
> > 
> > This concept is a valuable tool to allow for fast publishing of IP
> > address takeover in redundant-server situations.
> > 
> > There are ways in which it can be misused, but that doesn't make it an
> > invalid technique.
> 
> I don't think it would be too difficult to preserve this kind of
> functionality while improving security.  Is this really the only reason
> why nothing has been done to protect machines from ARP spoofing?
> 

Surely, you can do what you want with netfilter/arptables.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
