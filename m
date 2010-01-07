From: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Subject: Re: [PATCH 03/13] stmmac: add the new Header file for stmmac platform
 data
Date: Thu, 07 Jan 2010 08:46:43 -0500
Message-ID: <4B45E5C3.6060205@octasic.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com> <4B45DE02.5010403@octasic.com> <4B45E1D7.80407@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.octasic.com ([70.54.254.106]:22002 "EHLO
	MAILEXCH.octasic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab0AGNqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 08:46:45 -0500
In-Reply-To: <4B45E1D7.80407@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Giuseppe CAVALLARO wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Hi Jean-Hugues,
>
> Jean-Hugues Deschenes wrote:
>   
>> Coming to think of it, it might be preferable to locate this file in
>> drivers/net/stmmac/stmmac_plat.h and have the platform-specific code do
>> inclusions like: #include "../../../drivers/net/stmmac/stmmac_plat.h"
>>     
>
> Indeed, I don't like the include/linux/stmmac.h file but it's not only,
> see the dm9000.h file.
>
> Moreover, moving this header file within drivers/net/stmmac directory,
> each board setup file (arch/sh/boards/mach-<name>/setup.c should have
> #include "../../../../drivers/net/stmmac/stmmac_plat.h". Is it a good
> solution?
I took a look at the the arch subdirectory before suggesting this:
 grep -RI "^\#include.*\/drivers" *
m32r/platforms/usrv/io.c:#include "../../../../drivers/pcmcia/m32r_cfc.h"
s390/mm/cmm.c:#include "../../../drivers/s390/net/smsgiucv.h"
x86/kernel/asm-offsets_32.c:#include "../../../drivers/lguest/lg.h"

... so we wouldn't be the only ones... but then again, as with your 
Davicom dm9000.h example, we wouldn't be the only ones to locate it in 
include/linux either... so...?

jh
