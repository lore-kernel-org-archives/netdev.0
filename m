From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH] sky2: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 21:17:45 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712202115320.5453@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0712182008160.3616@mini.warudkars.net>
 <20071220091603.0d69b045@deepthought>
 <823114761-1198171803-cardhu_decombobulator_blackberry.rim.net-937108990-@bxe019.bisx.prod.on.blackberry>
  <20071220095121.7859c023@deepthought> <476ABDDF.8080607@intel.com>
 <476ABE7D.60901@linux.intel.com> <476AC105.9090206@intel.com>
 <82e4877d0712201200h7b994175u841d1efa047cefff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Parag Warudkar <parag.warudkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:53016 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbXLTUSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 15:18:08 -0500
In-Reply-To: <82e4877d0712201200h7b994175u841d1efa047cefff@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 20 Dec 2007, Parag Warudkar wrote:

> On Dec 20, 2007 2:22 PM, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>> ok, that's just bad and if there's no user-defineable limit to the deferral I
>> definately don't like this change.
>>
>> Can I safely assume that any irq will cause all deferred timers to run?
>
> I think even other causes for wakeup like process related ones will
> cause the CPU to go busy and run the timers.
> This, coupled with the fact that no one is yet able to reach 0 wakeups
> per second makes it pretty unlikely that deferrable timers will be
> deferred indefinitely.
>
>>
>> If this is the case then for e1000 this patch is still OK since the watchdog needs
>> to run (1) after a link up/down interrupt or (2) to update statistics. Those
>> statistics won't increase if there is no traffic of course...
>>
>
> I think it is reasonable for Network driver watchdogs to use a
> deferrable timer - if the machine is 100% IDLE there is no one needing
> the network to be up.

Please note tha being connected to a network does not only mean to send 
but also to receive.

Best regards,

 				Krzysztof Oledzki
