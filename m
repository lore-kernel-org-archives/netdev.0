From: Alexander H Duyck <alexander.h.duyck@intel.com>
Subject: Re: Question on RX packet classification in ethtool userspace
Date: Thu, 20 Jan 2011 09:24:46 -0800
Message-ID: <1295544286.4130.3.camel@ahduyck-mobl2.amr.corp.intel.com>
References: <80769D7B14936844A23C0C43D9FBCF0F25C04CB6B2@orsmsx501.amr.corp.intel.com>
	 <1295479169.2906.53.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"santwona.behera@sun.com" <santwona.behera@sun.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27986 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617Ab1ATRXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jan 2011 12:23:11 -0500
In-Reply-To: <1295479169.2906.53.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-19 at 15:19 -0800, Ben Hutchings wrote:
> On Wed, 2011-01-19 at 14:52 -0800, Duyck, Alexander H wrote:
> > So I was looking into the option of replacing the ETHTOOL_GRXNTUPLE
> > call with something like ETHTOOL_GRXCLSRLALL and it seems like I
> > wasn't having much luck finding the userspace implementation in the
> > ethtool.
> 
> I wasn't aware until now that there was a public implementation!
> 
> > I eventually found a patch in patchwork at
> > http://patchwork.ozlabs.org/patch/23223/ which is supposed to add
> > support but the current ethtool git tree doesn't appear to contain
> > this code.  I was wondering if I am missing something and it is on a
> > branch somewhere, or is this something that was not applied to the
> > userspace for some specific reason?
> 
> Thanks for digging this up.  It's not in any branch that I know of.  I'm
> about to go on vacation, but I'll look at it when I get back.  I would
> appreciate it if someone would refresh the patch against current ethtool
> (preferably reusing some of the functions added for the RX n-tuple
> operations).
> 
> Ben.
> 

I'll look into updating the patch.

Thanks,

Alex

