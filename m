From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac patches...
Date: Fri, 20 Nov 2009 08:19:14 +0100
Message-ID: <4B0642F2.7060308@st.com>
References: <20091119.121821.51205410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:46264 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754857AbZKTHTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 02:19:16 -0500
In-Reply-To: <20091119.121821.51205410.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi David,

David Miller wrote:
> Please do not intermix coding style changes with bug
> fixes.
> 
> In your second patch you change the indentation of
> the arguments to ->init_rx_desc() in stmmac_suspend()
> 
> Not only is this inappropriate in a bug fix patch, it
> is actually making the indentation incorrect.  The
> arguments should line up to the column after the
> function argument set openning '(' on the previous
> line.

I agree with you and thanks for your feedback.

> Please fix this up and resubmit both of your patches.

I've just resent the second patch:
 [PATCH (RESENT)] stmmac: do not fail when the timer cannot be used.
Let me know if I have to review something in my first patch as well.

Peppe

> 
> Thank you.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAksGQvIACgkQ2Xo3j31MSSKodQCgopGgPPXTU+K5xESR5WXawTlc
MagAn21fS/y+pCAuiOoJVbOU5Z79yqWt
=58TT
-----END PGP SIGNATURE-----
