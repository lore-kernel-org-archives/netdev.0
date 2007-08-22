From: Bruce Cole <bacole@gmail.com>
Subject: Re: r8169: slow samba performance
Date: Wed, 22 Aug 2007 12:46:24 -0700
Message-ID: <46CC9290.3040501@gmail.com>
References: <46CC66D3.8030602@gmail.com> <20070822182116.GA5445@csy.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shane <shane@cm.nu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:50477 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932406AbXHVTs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 15:48:27 -0400
Received: by rv-out-0910.google.com with SMTP id k20so297736rvb
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 12:48:26 -0700 (PDT)
In-Reply-To: <20070822182116.GA5445@csy.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shane wrote:
> On Wed, Aug 22, 2007 at 09:39:47AM -0700, Bruce Cole wrote:
>   
>> Shane, join the crowd :)  Try the fix I just re-posted over here:
>>     
>
> Bruce, gigabit speeds thanks for the pointer.  This fix
> works well for me though I just added the three or so lines
> in the elseif statement as it rejected with the
> r8169-20070818.  I suppose I could've merged the whole
> thing and if you need that tested, let me know but this is
> looking good.
>   
Glad it works for you.  I'm not the maintainer, and also don't have 
adequate specs from Realtek to definitively explain why the NPQ bit 
apparently needs to be re-enabled when some but not all of the TX FIFO 
is dequeued.  It is documented as if it isn't cleared until the FIFO is 
empty.  So I assume an official patch will have to wait until Francois 
is back.



