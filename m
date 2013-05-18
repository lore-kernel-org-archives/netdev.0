From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix offloaded tx checksum for small packets.
Date: Sat, 18 May 2013 12:10:32 +0200
Message-ID: <20130518101032.GB20930@electric-eye.fr.zoreil.com>
References: <20130516223857.GA20140@electric-eye.fr.zoreil.com>
 <1368745249.2655.60.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41721 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523Ab3ERKKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 06:10:47 -0400
Content-Disposition: inline
In-Reply-To: <1368745249.2655.60.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> :
[...]
> skb_checksum_help() can fail, though it is unlikely for such a short
> packet.  So I think this should be:
> 
> 			return skb_checksum_help(skb) == 0 && rtl_skb_pad(skb);

Will do. I don't have consistent test results anyway. :o(

Thanks.

-- 
Ueimor
