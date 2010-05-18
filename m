From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v3 3/3] ptp: Added a clock that uses the eTSEC found on
 the MPC85xx.
Date: Tue, 18 May 2010 11:23:38 -0500
Message-ID: <4BF2BF0A.8000405@freescale.com>
References: <cover.1273855016.git.richard.cochran@omicron.at> <ee6c3edca3ee6aa86565e59da999375f79c9de1b.1273855017.git.richard.cochran@omicron.at> <4BED8C91.8020107@freescale.com> <20100517082757.GA9703@riccoc20.at.omicron.at> <4BF18582.6000500@freescale.com> <20100518063608.GA2720@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:38629 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182Ab0ERQXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 12:23:52 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o4IGNeje002173
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 09:23:41 -0700 (MST)
Received: from az33exm25.fsl.freescale.net (az33exm25.am.freescale.net [10.64.32.16])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id o4IGNjfG013259
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 11:23:45 -0500 (CDT)
In-Reply-To: <20100518063608.GA2720@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2010 01:36 AM, Richard Cochran wrote:
> On Mon, May 17, 2010 at 01:05:54PM -0500, Scott Wood wrote:
>>>>>> +  - tmr_fiper1   Fixed interval period pulse generator.
>>>>>> +  - tmr_fiper2   Fixed interval period pulse generator.
>>>>
>>
>> MPC8572 and P2020 have fiper3 as well.
>
> I doubt they really have a third fiper.
>
> First of all, this signal is not routed anywhere on the boards.

OK, but that's a separate issue from whether it exists on the chip and 
could be used on a different board.

> Also, according to the documentation, it has no bit in the TMR_CTRL or the
> TMR_TEMASK registers.

It does seem inconsistent -- but could just be bad docs.

> Unless there is a bit in TMR_TEMASK, you cannot
> get an interrupt from it.
>
> If you cannot use the signal externally (in the "real" world) and you
> cannot get an interrupt, what good is it to have such a periodic
> signal? Polling the bit in the TMR_TEVENT to see when a pulse occurs
> seems pointless.
>
> Scott, you have connections, right? Can you clarify this for me?

I'll ask around.

-Scott
