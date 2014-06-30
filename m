From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net v2 3/3] net: stmmac: Improve mcast/ucast filter for all Synopsys EMAC Configurations
Date: Mon, 30 Jun 2014 08:46:24 +0200
Message-ID: <4380814.yCFVZiTZxJ@wuerfel>
References: <1404092110-18667-1-git-send-email-vbridgers2013@gmail.com> <1404092110-18667-4-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	peppe.cavallaro@st.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	robh+dt@kernel.org, dinguyen@altera.com, davem@davemloft.net,
	vbridger@altera.com
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:59618 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249AbaF3Gqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 02:46:34 -0400
In-Reply-To: <1404092110-18667-4-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 29 June 2014 20:35:10 Vince Bridgers wrote:
> The synopsys EMAC can be configured for different numbers of multicast hash
> bins and perfect filter entries at device creation time and there's no way
> to query this configuration information at runtime. As a result, a devicetree
> parameter is required in order for the driver to program these filters
> correctly for a particular device instance. This patch extends the current
> driver by providing a different multicast filter programming function if
> different than the currently supported 64 multicast hash bins and 32
> perfect unicast addresses. This patch is required to correct multicast
> filtering for the Altera Cyclone V SOC.
> 
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> 

No objections to the content of the patch, but it would be better to split
it out into two separate patches: one that does the mechanical prototype
and formatting changes, and a smaller one that actually introduces the
functional change. That would make it much easier to review, and to bisect
potential problems when something goes wrong.

	Arnd
