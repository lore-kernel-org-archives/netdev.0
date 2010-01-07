From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 03/13] stmmac: add the new Header file for stmmac platform
 data
Date: Thu, 07 Jan 2010 14:29:59 +0100
Message-ID: <4B45E1D7.80407@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com> <4B45DE02.5010403@octasic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:45987 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751550Ab0AGNad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 08:30:33 -0500
In-Reply-To: <4B45DE02.5010403@octasic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Jean-Hugues,

Jean-Hugues Deschenes wrote:
> 
> Giuseppe CAVALLARO wrote:
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>  include/linux/stmmac.h |   53
>> ++++++++++++++++++++++++++++++++++++++++++++++++
>>  1 files changed, 53 insertions(+), 0 deletions(-)
>>  create mode 100644 include/linux/stmmac.h
>>
>> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
>> new file mode 100644
>> index 0000000..32bfd1a
>> --- /dev/null
>> +++ b/include/linux/stmmac.h
>>   
> Coming to think of it, it might be preferable to locate this file in
> drivers/net/stmmac/stmmac_plat.h and have the platform-specific code do
> inclusions like: #include "../../../drivers/net/stmmac/stmmac_plat.h"

Indeed, I don't like the include/linux/stmmac.h file but it's not only,
see the dm9000.h file.

Moreover, moving this header file within drivers/net/stmmac directory,
each board setup file (arch/sh/boards/mach-<name>/setup.c should have
#include "../../../../drivers/net/stmmac/stmmac_plat.h". Is it a good
solution? So i can think the include/linux/stmmac.h remains the way
(like for  the architectures that use the Davicom DM9000 adapter).
At any rate, welcome advice as usual.

Regards,
Peppe

> 
> jh
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAktF4dcACgkQ2Xo3j31MSSKTFwCfXwrMhGK/3zin53G+oqMGgZgf
Y2AAmwWNvVARWEgM8VdNSyp5xY7ntlk6
=XwJD
-----END PGP SIGNATURE-----
