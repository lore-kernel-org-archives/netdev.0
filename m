From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000e: Hardware CRC stripping doesn't work with 82566DM-2
Date: Wed, 06 Feb 2008 13:43:31 -0800
Message-ID: <47AA2A03.2000109@intel.com>
References: <47AA1BB4.8010802@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johan Andersson <johan.andersson@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39710 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750812AbYBFVoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 16:44:23 -0500
In-Reply-To: <47AA1BB4.8010802@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johan Andersson wrote:
> Hi,
> 
> In commit 140a74802894e9db57e5cd77ccff77e590ece5f3 a workaround for crc
> stripping was removed.
> However, the hardware supported crc stripping now in use doesn't seem to
> work with the following chip:
> Intel Corporation 82566DM-2 Gigabit Network Connection (rev 02) (8086:10bd)
> 
> I discovered this while trying to make this nic member of a bridge.
> Since some frames get too large for the bridge they are dropped, making
> it impossible to use this nic in a bridge.
> 
> Reverting this commit makes the nic and brigde work again.
> 
> Are there any more chips in this family suffering from this?

I have only heard from this issue for 82566dm-2 chipsets, but I'm looking into it
atm (time permitting). It has been reported by Herbert Xu to cause issues in the
same matter last week.

I'm not sure what the real issue is right now, I hope to get an answer on this later.

Auke

