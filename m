From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 14:42:57 -0400
Message-ID: <20080516184257.GB27128@csclub.uwaterloo.ca>
References: <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <20080516132107.GA11304@csclub.uwaterloo.ca> <20080516161029.44ded734@core> <20080516173610.GA27126@csclub.uwaterloo.ca> <20080516191125.46f59ad6@core> <20080516184138.GF27126@csclub.uwaterloo.ca>
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
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:53891 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754311AbYEPSm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 14:42:58 -0400
Content-Disposition: inline
In-Reply-To: <20080516184138.GF27126@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 02:41:38PM -0400, Lennart Sorensen wrote:
> Well it isn't that things liks ssh and ssl and such don't need that
> level of security, but if there is no way to get it you have to go for
> the best you can get.  Fortunately it seems hardware RNG is becoming
> more common on embedded CPUs.

Of course in some cases, someone might be typing stuff at the serial
console and you get some actual random input, but you can't rely on it
being there, its nice to get it if its there though.

-- 
Len Sorensen
