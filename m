From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 03/13] stmmac: add the new Header file for stmmac platform
 data
Date: Thu, 07 Jan 2010 15:01:37 +0100
Message-ID: <4B45E941.1070002@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com> <4B45DE02.5010403@octasic.com> <4B45E1D7.80407@st.com> <4B45E5C3.6060205@octasic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:56204 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752079Ab0AGOBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 09:01:55 -0500
In-Reply-To: <4B45E5C3.6060205@octasic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Jean-Hugues,

Jean-Hugues Deschenes wrote:

> I took a look at the the arch subdirectory before suggesting this:
> grep -RI "^\#include.*\/drivers" *
> m32r/platforms/usrv/io.c:#include "../../../../drivers/pcmcia/m32r_cfc.h"
> s390/mm/cmm.c:#include "../../../drivers/s390/net/smsgiucv.h"
> x86/kernel/asm-offsets_32.c:#include "../../../drivers/lguest/lg.h"
> 
> ... so we wouldn't be the only ones... but then again, as with your
> Davicom dm9000.h example, we wouldn't be the only ones to locate it in
> include/linux either... so...?

Yes you are right :-) !
Another question. Indeed, for stm architectures, within each setup file,
we don't include the linux/stmmac.h (I was wrong before!) but include
linux/stm/platform.h. This own header includes the "linux/stmmac.h".
So using stmmac_plat.h, I should add: #include
"../../../drivers/net/stmmac/stmmac_plat.h"  within the
include/linux/stm/platform.h file. Is it ok? What do you think?

Thanks
Peppe

> 
> jh
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktF6UEACgkQ2Xo3j31MSSJ+WQCgpTM9z6/b7JaXq60TaQTN39P0
Tv0An3PFCB4nPUmxTUphrupPTp65mW2d
=kzPv
-----END PGP SIGNATURE-----
