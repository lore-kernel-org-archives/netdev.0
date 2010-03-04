From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Re: [net-next-2.6 PATCH] e1000e: do not modify tx queue len on
	link speed change
Date: Thu, 4 Mar 2010 06:41:00 -0800
Message-ID: <9929d2391003040641s10ceceeax1beb3bd618fb7eb5@mail.gmail.com>
References: <20100303143137.0BCA01220127@host64.kissl.de>
	 <20100304.004128.236847399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: franco@lastsummer.de, Brandeburg@host64.kissl.de,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	Allan@host64.kissl.de, bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:53374 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab0CDOlD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 09:41:03 -0500
Received: by pvb32 with SMTP id 32so370252pvb.19
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 06:41:01 -0800 (PST)
In-Reply-To: <20100304.004128.236847399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 4, 2010 at 00:41, David Miller <davem@davemloft.net> wrote:
> From: franco@lastsummer.de
> Date: Wed, =C2=A03 Mar 2010 15:31:37 +0100 (CET)
>
>> e1000e would try to set appropriate values of tx_queue_len for
>> negotiated
>> link speeds overwriting the already set configuration of tx_queue_le=
n in
>> the process. This removes all lines touching tx_queue_len from the
>> driver.
>>
>> Signed-off-by: Franco Fichtner <franco@lastsummer.de>
>
> Intel folks, you got this?

Yes, I have added it to my queue of patches.  Sorry for the delayed res=
ponse.

--=20
Cheers,
Jeff
