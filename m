From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Wed, 27 Oct 2010 09:05:52 -0700 (PDT)
Message-ID: <20101027.090552.189686029.davem@davemloft.net>
References: <AANLkTik2Q=fF9j6eiBQx33e2JU7EG3Sc5hnXyDH24+mt@mail.gmail.com>
	<20101027.085115.104074771.davem@davemloft.net>
	<AANLkTikhhsEu7zzYpEH-Dby_Ke77iSo0z1wu2t-xU+Jc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761145Ab0J0QF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 12:05:29 -0400
In-Reply-To: <AANLkTikhhsEu7zzYpEH-Dby_Ke77iSo0z1wu2t-xU+Jc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Wed, 27 Oct 2010 09:01:25 -0700

> On Wed, Oct 27, 2010 at 8:51 AM, David Miller <davem@davemloft.net> wrote:
>>> As the patch stands, they don't. Only autoconfigured addresses will be
>>> cleared, because addrconf_ifdown() does not remove any addresses that
>>> are permanent (unless they are link-local, in which case they are
>>> recreated as soon as link comes back).
>>
>> Ok, and that brings us back to the issue of losing a TCP connection
>> over a link-local et al. address during a minor link flap.
> 
> TCP connections don't go away when the address they are using goes
> away. They go away if their address goes away forever. As mentioned
> above in the thread, I did test this :)

Ok, that's good enough for me :)
