From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [RESEND PATCH 1/4] stmmac: thinking about a generic driver for
 Synopsys Controllers.
Date: Mon, 04 Jan 2010 08:21:01 +0100
Message-ID: <4B4196DD.5080902@st.com>
References: <1260948405-28511-1-git-send-email-peppe.cavallaro@st.com> <20091225.182645.59702958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:56007 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751419Ab0ADHVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 02:21:15 -0500
In-Reply-To: <20091225.182645.59702958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi David,

David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Wed, 16 Dec 2009 08:26:42 +0100
> 
>> The idea behind this patch is to start thinking about a
>> generic driver for Synopsys Ethernet Controllers
>> starting from the stmmac device driver.
> 
> This patch does too much at once.
> 
> It changes Kconfig help test.
> 
> It moves many things around to many new files.
> 
> It's therefore too large to review as a unit.
> 
> Please split this up into several (many) pieces.
> One for each specific action.
> 
> One patch might improve the help test.  Another might
> move DMA operations out to a seperate file, another might
> move another class of operations into a new file.
> 
> And at each step of the way the driver must compile and work
> properly.

I'll do that and resend all the patches to be reviewed.

Thanks,
Peppe

> 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktBlt0ACgkQ2Xo3j31MSSIgFACfQ5rxaIYicsllguP7uvo5tHQe
8n8AoLSLLdB4BG+7G/vgiOEfrntlwnSH
=1Gvi
-----END PGP SIGNATURE-----
