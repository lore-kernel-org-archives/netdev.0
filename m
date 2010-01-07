From: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Subject: Re: [PATCH 03/13] stmmac: add the new Header file for stmmac platform
 data
Date: Thu, 07 Jan 2010 09:34:50 -0500
Message-ID: <4B45F10A.3050508@octasic.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com> <4B45DE02.5010403@octasic.com> <4B45E1D7.80407@st.com> <4B45E5C3.6060205@octasic.com> <4B45E941.1070002@st.com> <4B45EC4B.10602@octasic.com> <4B45EDB8.3070601@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.octasic.com ([70.54.254.106]:30236 "EHLO
	MAILEXCH.octasic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868Ab0AGOev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 09:34:51 -0500
In-Reply-To: <4B45EDB8.3070601@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Giuseppe CAVALLARO wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Jean-Hugues Deschenes wrote:
>   
>> Hi Giuseppe,
>>
>> Giuseppe CAVALLARO wrote:
>>     
>>> Another question. Indeed, for stm architectures, within each setup file,
>>> we don't include the linux/stmmac.h (I was wrong before!) but include
>>> linux/stm/platform.h. This own header includes the "linux/stmmac.h".
>>> So using stmmac_plat.h, I should add: #include
>>> "../../../drivers/net/stmmac/stmmac_plat.h"  within the
>>> include/linux/stm/platform.h file. Is it ok? What do you think?
>>>
>>>       
>> I believe that would work out well.
>>
>> ... Although I wonder if the whole stm subdirectory should be in
>> include/linux, rather than in arch/sh...
>>     
> Sorry, I was not not clear before. the  stm subdirectory is in
> include/linux.
>   
You were quite clear; sorry, my mistake; I should have written "... 
Although I wonder if the whole stm subdirectory should be in arch/sh, 
rather than in
include/linux..."

> In fact, my previous question was if it's good to include
> ../../../drivers/net/stmmac/stmmac_plat.h within the
> include/linux/stm/platform.h file.
>   
I don't see a problem with that, although we'd be the first doing it... 
probably as long as the include
../../../drivers/net/stmmac/stmmac_plat.h is surrounded by the 
appropriate #ifdef CONFIG_STMMAC_ETH?

>  But that's another story... It
>   
>> is there because you maintain both sh and arm-base SOCs right?
>>     
> Yes you are right!
>   
... so ideally, you'need some kind of arch/common, arch/shared or 
include/linux/platform directory of some kind... Too bad such a thing 
doesn't exist...

Regards,
jh
