From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 route to gateway on fe80::1%eth0 when I have fe80::1%br0
 locally
Date: Mon, 22 Feb 2016 17:15:41 +0100
Message-ID: <56CB342D.9010100@stressinduktion.org>
References: <20151212195830.GA18286@torres.zugschlus.de>
 <56796902.8080703@stressinduktion.org>
 <20151222212843.GE4424@torres.zugschlus.de>
 <5679C58C.2090308@stressinduktion.org>
 <20160222150443.GV26042@torres.zugschlus.de>
 <56CB2564.9030003@stressinduktion.org>
 <20160222154758.GW26042@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:54734 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746AbcBVQPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 11:15:45 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id B6D8320E6F
	for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 11:15:44 -0500 (EST)
In-Reply-To: <20160222154758.GW26042@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.02.2016 16:47, Marc Haber wrote:
> Can you reproduce the behavior with accept_ra_from_local =0 as well?
> Unfortunately, the debugging VM I build works fine, it's just the
> physical host showing this behavior. This is really strange.

Same here. Debugging VM didn't show this error at all and other systems 
didn't show this symptom either (4.4.2 as well as net-next).

With which kernel did you see this behavior for the first time and what 
was the last working version?

Bye,
Hannes
