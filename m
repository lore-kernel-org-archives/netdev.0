From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [RESEND][PATCH 2.6.27-rc3] ixp4xx_eth: fix dma_mapping_error() compile errors
Date: Thu, 14 Aug 2008 20:46:07 +0200
Message-ID: <m3zlnfl9jk.fsf@maximus.localdomain>
References: <200808131908.m7DJ8EAp013777@harpo.it.uu.se>
	<48A3ECBE.9050909@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mikael Pettersson <mikpe@it.uu.se>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:41090 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757538AbYHNSqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 14:46:08 -0400
In-Reply-To: <48A3ECBE.9050909@garzik.org> (Jeff Garzik's message of "Thu\, 14 Aug 2008 04\:28\:46 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> writes:

>> dma_mapping_error() changed in 2.6.27-rc1 to also take a device parameter,
>> but nobody bothered updating ixp4xx_eth.c. Fixed by passing the appropriate
>> device value in the dma_mapping_error() calls.
>>
>> Tested on an ixp425 box.
>>
>> Signed-off-by: Mikael Pettersson <mikpe@it.uu.se>
>> Acked-by: Krzysztof Halasa <khc@pm.waw.pl>

Thanks a lot.
-- 
Krzysztof Halasa
