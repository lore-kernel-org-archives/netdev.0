From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 03/13] stmmac: add the new Header file for stmmac platform
 data
Date: Thu, 07 Jan 2010 15:20:40 +0100
Message-ID: <4B45EDB8.3070601@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com> <4B45DE02.5010403@octasic.com> <4B45E1D7.80407@st.com> <4B45E5C3.6060205@octasic.com> <4B45E941.1070002@st.com> <4B45EC4B.10602@octasic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:39094 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553Ab0AGOUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 09:20:45 -0500
In-Reply-To: <4B45EC4B.10602@octasic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Jean-Hugues Deschenes wrote:
> Hi Giuseppe,
> 
> Giuseppe CAVALLARO wrote:
>> Another question. Indeed, for stm architectures, within each setup file,
>> we don't include the linux/stmmac.h (I was wrong before!) but include
>> linux/stm/platform.h. This own header includes the "linux/stmmac.h".
>> So using stmmac_plat.h, I should add: #include
>> "../../../drivers/net/stmmac/stmmac_plat.h"  within the
>> include/linux/stm/platform.h file. Is it ok? What do you think?
>>  
> I believe that would work out well.
> 
> ... Although I wonder if the whole stm subdirectory should be in
> include/linux, rather than in arch/sh...

Sorry, I was not not clear before. the  stm subdirectory is in
include/linux.
In fact, my previous question was if it's good to include
./../../drivers/net/stmmac/stmmac_plat.h within the
include/linux/stm/platform.h file.

 But that's another story... It
> is there because you maintain both sh and arm-base SOCs right?

Yes you are right!

Peppe

> 
> thanks,
> jh
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktF7bgACgkQ2Xo3j31MSSIKAgCgsEnwCKaYFsbpiEz4KAB370tJ
UxAAoLucaQqakElDfQHRYbn11zMhwIFB
=56bk
-----END PGP SIGNATURE-----
