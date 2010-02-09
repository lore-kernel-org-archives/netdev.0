From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [Bugme-new] [Bug 15239] New: Problem with network performance
 after a while.
Date: Tue, 09 Feb 2010 08:19:47 +0100
Message-ID: <4B710C93.9010603@itcare.pl>
References: <bug-15239-10286@http.bugzilla.kernel.org/>	<20100208141513.b5d0be56.akpm@linux-foundation.org> <20100208.145531.143618406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, pstaszewski@artcom.pl, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r242-20.iq.pl ([86.111.242.20]:33294 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751241Ab0BIHTr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 02:19:47 -0500
In-Reply-To: <20100208.145531.143618406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-02-08 23:55, David Miller pisze:
> From: Andrew Morton<akpm@linux-foundation.org>
> Date: Mon, 8 Feb 2010 14:15:13 -0800
>
>    
>> That would be bad.  That's a regression in 2.6.33-rc, and we've
>> backported that regression into 2.6.32.x -stable.
>>      
> Luckily we have a fix already. :-)
>    

Yes - i make bugreport and after i write also here on the list

And Eric Dumazet help to solve problem with "route cache" - and locking 
load on one cpu after information about "route cache disabled".

After his patch i don't see any errors in dmesg.


But i think there is a little more in my bugreport on bugzilla.



Regards
Pawel

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>    

