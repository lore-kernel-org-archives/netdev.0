From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 1/5] stmmac: add CHAINED descriptor mode support
Date: Wed, 12 Oct 2011 08:37:31 +0200
Message-ID: <4E9535AB.6020608@st.com>
References: <1318318246-1326-1-git-send-email-peppe.cavallaro@st.com> <1318318246-1326-2-git-send-email-peppe.cavallaro@st.com> <20111011.154203.569015025155780686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rayagond@vayavyalabs.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:56782 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752207Ab1JLHEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 03:04:39 -0400
In-Reply-To: <20111011.154203.569015025155780686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/2011 9:42 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Tue, 11 Oct 2011 09:30:42 +0200
> 
>> From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
>>
>> This patch enhances the STMMAC driver to support CHAINED mode of
>> descriptor (useful also on validation side).
>>
>> STMMAC supports DMA descriptor to operate both in dual buffer(RING)
>> and linked-list(CHAINED) mode. In RING mode (default) each descriptor
>> points to two data buffer pointers whereas in CHAINED mode they point
>> to only one data buffer pointer.
>>
>> In CHAINED mode each descriptor will have pointer to next descriptor in
>> the list, hence creating the explicit chaining in the descriptor itself,
>> whereas such explicit chaining is not possible in RING mode.
>>
>> Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
>> Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> 
> These ifdefs added all over the place in the foo.c files are terrible.
> 
> Abstract out the differences between RING and CHAINED mode into helper
> inline routines which live in some foo.h header file, that way you won't
> need any ifdefs in the driver foo.c files.

Hello David

I'll rework the patch and send all these updates to the mailing list
again (as V2).

Peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
