From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: Unconditionally disabling ASPM
Date: Sun, 15 May 2016 20:42:01 +0200
Message-ID: <20160515184201.GA23445@electric-eye.fr.zoreil.com>
References: <1463330971.6071.35.camel@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	David Miller <davem@davemloft.net>,
	Chunhao Lin <hau@realtek.com>
To: Paul Menzel <paulepanter@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34591 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbcEOSm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 14:42:26 -0400
Content-Disposition: inline
In-Reply-To: <1463330971.6071.35.camel@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Menzel <paulepanter@users.sourceforge.net> :
[...]
> As over five years have passed now, do you think that is still needed?
> I wonder why no module parameter was added back then, where users could
> enable ASPM if it works on their systems? Because there is no such
> situation and it always fails?

It was enabled again (d64ec841517a25f6d468bde9f67e5b4cffdc67c7) then
disabled (4521e1a94279ce610d3f9b7945c17d581f804242). It's closer
to 3.5 years :o)

Module parameters are frowned upon.

Lin, is there some interest in selectively [*] enabling (or disabling)
ASPM support in the r8169 driver or will it be unreliable ?

[*] Based on DMI information for instance.

-- 
Ueimor
