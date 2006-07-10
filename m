From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx-d80211: Fix an off-by-one condition in handle_irq_noise
Date: Mon, 10 Jul 2006 18:11:06 -0500
Message-ID: <44B2DE8A.2020204@lwfinger.net>
References: <44B2DB2F.9090602@lwfinger.net> <200607110102.52444.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:23995 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1422795AbWGJXLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 19:11:12 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607110102.52444.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 11 July 2006 00:56, you wrote:
>> An assert statement near the start of handle_irq_noise in the d80211 version of bcm43xx_main.c is 
>> there to protect against out of bound addressing using variable bcm->noisecalc.nr_samples. The 
>> arrays in question have a dimension of 8, thus the value must be < 8. This patch mirrors the one 
>> submitted earlier for the softmac version of bcm43xx.
>>
>> Signed-Off-By: Larry.Finger <Larry.Finger@lwfinger.net>
>>
>> ========================================================
>>
>> index 7ed18ca..37bb0dd 100644
>> --- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> 
> This is not a patch against bcm43xx-d80211.
> 

Sorry. I misunderstood the organization of wireless-dev. The correct patch will be sent shortly.

Larry
