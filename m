From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 03/13] stmmac: add the new Header file for stmmac platform
 data
Date: Thu, 07 Jan 2010 16:03:02 +0100
Message-ID: <4B45F7A6.5010008@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com> <4B45DE02.5010403@octasic.com> <4B45E1D7.80407@st.com> <4B45E5C3.6060205@octasic.com> <4B45E941.1070002@st.com> <4B45EC4B.10602@octasic.com> <4B45EDB8.3070601@st.com> <4B45F10A.3050508@octasic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:42775 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751811Ab0AGPDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 10:03:20 -0500
In-Reply-To: <4B45F10A.3050508@octasic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Jean-Hugues Deschenes wrote:
> Giuseppe CAVALLARO wrote:
>> In fact, my previous question was if it's good to include
>> ../../../drivers/net/stmmac/stmmac_plat.h within the
>> include/linux/stm/platform.h file.
>>   
> I don't see a problem with that, although we'd be the first doing it...
> probably as long as the include
> ../../../drivers/net/stmmac/stmmac_plat.h is surrounded by the
> appropriate #ifdef CONFIG_STMMAC_ETH?

Hi Jean-Hugues,
I can rework this moving the stmmac platform header from
 include/linux/stmmac.h
to
 drivers/net/stmmac/stmmac_plat.h

On stlinux kernel the include/linux/stm/platform.h header will include
../../../drivers/net/stmmac/stmmac_plat.h instead of linux/stmmac.h.

Any other comments?

To David: I've also removed __FILE__ as you had already suggested.

Many Thanks.
Regards,
Peppe

>>  But that's another story... It
>>  
>>> is there because you maintain both sh and arm-base SOCs right?
>>>     
>> Yes you are right!
>>   
> ... so ideally, you'need some kind of arch/common, arch/shared or
> include/linux/platform directory of some kind... Too bad such a thing
> doesn't exist...
> Regards,
> jh
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktF96UACgkQ2Xo3j31MSSLG2wCgsc0SNGLgkXrlzvLq+moQst2D
QvgAnAxTAB5np8Xc3d6rF1+9nftk6nxP
=GL1t
-----END PGP SIGNATURE-----
