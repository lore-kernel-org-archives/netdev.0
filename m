From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/4] stmmac: thinking about a generic driver for Synopsys
 Controllers.
Date: Thu, 03 Dec 2009 11:42:30 +0100
Message-ID: <4B179616.2010907@st.com>
References: <1259836805-7512-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:53600 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755879AbZLCKm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 05:42:29 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8D3A4B6
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2009 10:42:33 +0000 (GMT)
Received: from mail1.ctn.st.com (mail1.ctn.st.com [164.130.116.128])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5428EA70
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2009 10:42:33 +0000 (GMT)
In-Reply-To: <1259836805-7512-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Giuseppe CAVALLARO wrote:
> The idea behind this patch is to start thinking about a
> generic driver for Synopsys Ethernet Controllers
> starting from the stmmac device driver.
> In the future, the stmmac could be also renamed as "synmac";
> I'd like to see it working on other systems with other CPUs
> (ARM, SH) and other Synopsys Ethernet IPs.

Folks,
after releasing the first version of this driver, many people contacted
me asking to candidate the stmmac as generic device driver for Synopsys.
So this is the meaning of this patch I'm sending the Community.
I do hope that could help other developers.

The driver continues to work on stlinux platforms (tested on several
board with mac100 and gmac controllers).

I'm also thinking to rename the driver as "synmac" (instead of stmmac).
What do you think?
Welcome advice and review as usual.

Regards,
Peppe

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAksXlhYACgkQ2Xo3j31MSSJNVgCgrFPzJqw0iS+0Hh22Zs7rQloT
IsgAoJuBubpOzz5y6VKGctYl0Avvjhk8
=TbCM
-----END PGP SIGNATURE-----
