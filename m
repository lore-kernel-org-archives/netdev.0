From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] drivers: net: ethernet: stmmac: fix failure in
 module test
Date: Tue, 22 May 2012 12:56:05 +0100
Message-ID: <1337687765.11796.11.camel@deadeye>
References: <1337672336-7378-1-git-send-email-lliubbo@gmail.com>
	 <1337672336-7378-2-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <peppe.cavallaro@st.com>,
	<francesco.virlinzi@st.com>, <rayagond@vayavyalabs.com>,
	<sr@denx.de>, <netdev@vger.kernel.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>
To: Bob Liu <lliubbo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27840 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750974Ab2EVL4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 07:56:16 -0400
In-Reply-To: <1337672336-7378-2-git-send-email-lliubbo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 15:38 +0800, Bob Liu wrote:
> Module can't be compiled and installed in current Makefile.
[...]

That's because CONFIG_STMMAC_PLATFORM and CONFIG_STMMAC_PCI are wrongly
declared as tristate in Kconfig.  Change them to bool and it should work
again.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
