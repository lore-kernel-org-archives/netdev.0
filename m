From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [patch 09/11] forcedeth: improve NAPI logic
Date: Fri, 27 Apr 2007 14:57:16 -0400
Message-ID: <20070427185716.GA5578@csclub.uwaterloo.ca>
References: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net> <4630B76C.7070603@nvidia.com> <4630EE50.4000109@garzik.org> <4630BCD0.9040702@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, mingo@elte.hu
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:42165 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757050AbXD0S5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 14:57:17 -0400
Content-Disposition: inline
In-Reply-To: <4630BCD0.9040702@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 10:53:04AM -0400, Ayaz Abdulla wrote:
> Ok. In that case, the patch needs to be improved.
> 
> The following needs to be done when NAPI is enabled:
> - remove the tx handling within the ISRs
> - mask off the tx interrupts within the ISRs that handle tx processing
> - re-enable tx interrupts within the NAPI handler
> - add tx handling within the NAPI handler (this patch covers it)

I thought a number of drivers handled tx from napi while receives were
happening, but went to plain interrupts if no receives were happening.
Maybe I misread the code (I have mainly dealt with pcnet32 so far).
Certainly for gigabit I would think napi all the time would be much more
efficient.

--
Len Sorensen
