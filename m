From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 1/4] stmmac: remove two useless initialisation
Date: Mon, 04 Jun 2012 17:58:18 +0200
Message-ID: <4FCCDB1A.1080307@st.com>
References: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com> <1338824270-9222-2-git-send-email-peppe.cavallaro@st.com> <20120604.114940.813410325113851773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:41192 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752297Ab2FDP62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:58:28 -0400
In-Reply-To: <20120604.114940.813410325113851773.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/4/2012 5:49 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Mon,  4 Jun 2012 17:37:47 +0200
> 
>> This patch removes two useful initialisation in the
>> stmmac_rx and stmmac_tx function.
>> In the former, count var was already reset and in the
>> stmmac_tx we only need to increment the dirty pointer
>> w/o setting the entry var.
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> 
> There are so many problems with this patch I do not know where
> to start.
> 
> Your subject line says the initializations are "useless" yet
> your commit message says they are "useful".

Sorry, I meant "useless".

> This is a cleanup, and does not fix any bugs, and is therefore
> absolutely not appropriate for the 'net' tree.

Yes this is not a fix but a cleanup.

I've not clear where I have to post this patch.
Do you mean, w/o net.git entry in the patch subject?
Can you tell me what I have to do? So will resend all the patches again
but I'll be more careful on all.

> I'm tossing this entire series, you need to be more careful
> with your submissions.

ok, thanks a lot.

peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
