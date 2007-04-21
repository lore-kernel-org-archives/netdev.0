From: Andi Kleen <ak@suse.de>
Subject: Re: SIOCGIFCOUNT
Date: Sat, 21 Apr 2007 11:48:52 +0200
Message-ID: <200704211148.52705.ak@suse.de>
References: <200704210004.51278.ak@suse.de> <20070420.154133.76947512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:53411 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754539AbXDUJsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Apr 2007 05:48:55 -0400
In-Reply-To: <20070420.154133.76947512.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 April 2007 00:41:33 David Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Sat, 21 Apr 2007 00:04:51 +0200
> 
> > 0x8938 is SIOCGIFCOUNT. As far as I can see it is only defined in
> > sockios.h, but not implemented?
> >
> > Should it be removed from the include file or implemented?
> 
> Unless we can be %100 certain not one build will break by removing it,
> we should keep it around.

Ok, but should it not be implemented for the non compat case too?
I assume java has some reason to call it.

-Andi
