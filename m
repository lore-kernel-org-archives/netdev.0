From: john@BlueSkyTours.com
Subject: Re: r8169: slow samba performance
Date: Mon, 27 Aug 2007 16:34:50 -0600 (MDT)
Message-ID: <Pine.SOC.4.64.0708271631330.871@katana>
References: <46CC66D3.8030602@gmail.com> <20070822182116.GA5445@csy.ca>
 <46CC9290.3040501@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Bruce Cole <bacole@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat1.blueskytours.com ([12.96.192.180]:21757 "HELO
	volcano.blueskytours.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1754542AbXH0Wld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 18:41:33 -0400
In-Reply-To: <46CC9290.3040501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 22 Aug 2007, Bruce Cole wrote:

> Shane wrote:
>> On Wed, Aug 22, 2007 at 09:39:47AM -0700, Bruce Cole wrote:
>> 
>>> Shane, join the crowd :)  Try the fix I just re-posted over here:
>>> 
>> 
>> Bruce, gigabit speeds thanks for the pointer.  This fix
>> works well for me though I just added the three or so lines
>> in the elseif statement as it rejected with the
>> r8169-20070818.  I suppose I could've merged the whole
>> thing and if you need that tested, let me know but this is
>> looking good.
>> 
> Glad it works for you.  I'm not the maintainer, and also don't have adequate 
> specs from Realtek to definitively explain why the NPQ bit apparently needs 
> to be re-enabled when some but not all of the TX FIFO is dequeued.  It is 
> documented as if it isn't cleared until the FIFO is empty.  So I assume an 
> official patch will have to wait until Francois is back.


I have had abysmal performance trying to remotely run X apps via ssh on a
computer with a RTL8111 NIC.  Saw this message and decided to give this
patch a try --- success!  Much, much better.

Thanks,

John
