From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac latest patches  (Dec09)
Date: Wed, 16 Dec 2009 08:26:04 +0100
Message-ID: <4B288B8C.3050306@st.com>
References: <1259836805-7512-1-git-send-email-peppe.cavallaro@st.com> <4B179616.2010907@st.com> <4B20F8FE.90804@st.com> <4B2110D2.9050801@octasic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:56951 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933588AbZLPH0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 02:26:15 -0500
In-Reply-To: <4B2110D2.9050801@octasic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Jean,
Jean-Hugues Deschenes wrote:
> 
> 
> Giuseppe CAVALLARO wrote:
>> - - [PATCH 1/4] stmmac: thinking about a generic driver for Synopsys
>> Controllers.
>>   
> Looks good to me. This way, the driver architecture will more closely

Many thanks for your prompt feedback! This was the first goal of this patch.

> follow the Synopsys IP architecture.
>> - - [PATCH 2/4] stmmac: add the new Header file for stmmac platform data
>> - - [PATCH 3/4] stmmac: use MII_BUS_ID_SIZE instead of  BUS_ID_SIZE
>> - - [PATCH 4/4] stmmac: convert unicast addr list to list_head
>>   
> These 3 basically fix build errors with the newer kernels. great.

Yes, you are right.

- ---
I'm resending the patches reworked to be applied against the updated
net-2.6 Git.

Feel free to give me any advice and feedback. Welcome review as usual.
I think, it's worth having this patch subset on net-2.6 also to help
other developers to start working on this driver.

Any news about the idea to rename the stmmac as synmac?
I'm wondering if this could be done for the net-next-2.6 repository.
Please, David, Eric, what do you think?

Best Regards,
Giuseppe
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAksoi4QACgkQ2Xo3j31MSSLpfACfWLVrkb4S4dxqkLLvUWwyFmDC
K7kAnjMEaeC7bxYZFXSwD4MaZq74OAv6
=i0vU
-----END PGP SIGNATURE-----
