From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFT] sky2: 32 bit DMA quirk
Date: Thu, 8 Dec 2011 15:26:14 -0800
Message-ID: <20111208152614.37a8379b@s6510.linuxnetplumber.net>
References: <20111120232118.GA29748@ntm.wq.cz>
	<20111121160543.2ae9c04c@nehalam.linuxnetplumber.net>
	<20111122094234.GA28500@ntm.wq.cz>
	<20111126161513.GA5299@ntm.wq.cz>
	<20111126170331.744025f1@s6510.linuxnetplumber.net>
	<20111205124725.GA19385@ntm.wq.cz>
	<20111205081611.52ec0664@nehalam.linuxnetplumber.net>
	<20111206095919.GA6726@ntm.wq.cz>
	<20111207150205.3fad9290@nehalam.linuxnetplumber.net>
	<20111208195833.GA13613@ntm.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59401 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182Ab1LHX0U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 18:26:20 -0500
In-Reply-To: <20111208195833.GA13613@ntm.wq.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Dec 2011 20:58:33 +0100
Milan Kocian <milon@wq.cz> wrote:

> Hello Stephen,
> 
> On Wed, Dec 07, 2011 at 03:02:05PM -0800, Stephen Hemminger wrote:
> > This a patch to force 32 bit DMA. Not sure if the DMI values
> > are right for the Gigabyte motherboard with the problem.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> 
> Unfortunately it didn't help. I tried parameter
> only_32bit_dma=1 alone and then with parameter disable_msi=1
> with the same result.

Thanks for trying. Looks like not worth bothering investigating further.
