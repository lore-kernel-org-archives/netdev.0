From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [5/6] mvneta: implement SGMII-based in-band link state
 signaling
Date: Thu, 9 Jul 2015 11:19:41 +0200
Message-ID: <20150709111941.6a49091f@free-electrons.com>
References: <55155D9D.6070800@list.ru>
	<alpine.LNX.2.02.1507081757260.28659@sbrk.org>
	<559D5520.3030700@list.ru>
	<alpine.LNX.2.02.1507091040530.23853@sbrk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stas Sergeev <stsp@list.ru>, netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Sebastien Rannou <mxs@sbrk.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:42740 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750893AbbGIJTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 05:19:45 -0400
In-Reply-To: <alpine.LNX.2.02.1507091040530.23853@sbrk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastien, Stas,

On Thu, 9 Jul 2015 11:03:26 +0200 (CEST), Sebastien Rannou wrote:
> On Wed, 8 Jul 2015, Stas Sergeev wrote:
> 
> > What is there? A phy chip, or something else?
> 
> It's "something else", there's a phy which aggregates 4xSGMIIs to
> 1xQSGMII, we are on the media side here, the MAC side is connected
> to the switch through QSGMII.
> 
> > Perhaps some DT property should be added to explicitly
> > enable the use of the inband status...
> 
> Yes, that would be fine.

Isn't it a bit weird to need a new DT property for this? Shouldn't
fixed-link always imply this inband status thing?

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
