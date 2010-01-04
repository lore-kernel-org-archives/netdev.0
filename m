From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] phy: SMSC device Energy Detect power-down mode
Date: Mon, 04 Jan 2010 11:01:09 +0100
Message-ID: <4B41BC65.6060301@st.com>
References: <1260948498-28544-1-git-send-email-peppe.cavallaro@st.com> <20091225.183829.246551084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:39092 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751785Ab0ADK3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 05:29:10 -0500
In-Reply-To: <20091225.183829.246551084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi David,

David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Wed, 16 Dec 2009 08:28:18 +0100
> 
>> SMSC Ethernet Transceivers (LAN88710, LAN8710, LAN8720, LAN8187,
>> LAN8700, LAN83C185) provide a mechanism to conserve power when
>> the device is not connected to an active link partner
>> (Energy Detect Mode).
>> So this patch enables the Energy Detect power-down mode
>> for these Transceivers.
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> 
> Both phy_read() and phy_write() can return errors, you must check
> for them.  The rest of this driver does this properly.

I'm resending the patch with this fixed.
Thanks,
Peppe
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktBvGUACgkQ2Xo3j31MSSLA/gCfRSXQ7i/GEiZjPAHV4ZUxoxM5
YTUAoIPTXQ82zgsjj3q1gSdn1vY0G/dr
=fJnv
-----END PGP SIGNATURE-----
