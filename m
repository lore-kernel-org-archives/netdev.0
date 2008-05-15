From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 15:11:35 -0400
Message-ID: <482C8AE7.7070709@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>	<20080515142154.0595e475@core>	<36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>	<20080515173939.1ec968be@core> <482C7DA3.1090809@garzik.org> <482C8606.6000308@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52396 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbYEOTLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 15:11:44 -0400
In-Reply-To: <482C8606.6000308@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> Jeff Garzik wrote:
>>
>>
>> The Treacherous Platform Module includes an RNG.
>>
>> Someone (hi Jesse?) should implement support for TPM_GetRandom.
>>
>> All the specs are public, and the hardware is already in users' hands.
> 
> I will not pretend to understand everything mentioned, but having web 
> searched on "TPM RNG" I came across this:
> 
> http://www.mail-archive.com/cryptography@metzdowd.com/msg06299.html
> 
> which may either encourage or discourage depending on one's point of view.

Yep, in theory you can do it in userspace right now, with zero kernel 
modifications.

But just my gut feeling about the Treacherous Platform Module makes me 
think we should have a kernel driver, for both ease of use, and ease of 
replacement should that usage turn out to be unwise.

	Jeff



