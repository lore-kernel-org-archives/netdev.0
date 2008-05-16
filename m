From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 13:36:10 -0400
Message-ID: <20080516173610.GA27126@csclub.uwaterloo.ca>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <20080516132107.GA11304@csclub.uwaterloo.ca> <20080516161029.44ded734@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:49609 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752005AbYEPRgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 13:36:11 -0400
Content-Disposition: inline
In-Reply-To: <20080516161029.44ded734@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 04:10:29PM +0100, Alan Cox wrote:
> Ethernet is observable so ethernet isn't entropy. There is no "anything
> else" here -> there is no *anything*

So what is one to do if a few applications want to read from /dev/random
but you have no excellent source of entropy on the system?  Wait
forever?  I think ethernet interrupts are better than nothing, and I
really doubt that someone would be able to predict what the entropy
generated would be in practice.  If you have that good access to the
physical network, then probably have physical access to the system
itself, in which case it is all irrelevant.

-- 
Len Sorensen
