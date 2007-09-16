From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver and samba
Date: Sun, 16 Sep 2007 13:03:31 -0700
Message-ID: <46ED8C13.3010303@intel.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
 <46EAC25B.2060404@intel.com>
 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
 <46EAF644.1040006@intel.com> <46EC1A00.2000304@katalix.com>
 <46EC2D5A.7080504@intel.com> <46ED58AF.1070000@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	L F <lfabio.linux@gmail.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:39082 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbXIPUEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 16:04:11 -0400
Received: from ahkok-mobl.jf.intel.com ([71.182.85.189])
 by vms042.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JOH0019092A81M5@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Sun, 16 Sep 2007 15:03:46 -0500 (CDT)
In-reply-to: <46ED58AF.1070000@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> Kok, Auke wrote:
>> James Chapman wrote:
>>> Kok, Auke wrote:
> 
>>>>>      rx_long_byte_count: 34124849453
>>>
>>> Are these long frames expected in your network? What is the MTU of
>>> the transmitting clients? Perhaps this might explain why reads work
>>> (because data is coming from the Linux box so the packets have
>>> smaller MTU) while writes cause delays or packet loss because the
>>> clients are sending long frames which are getting fragmented?
>>
>> those are not "long frames" but the number of bytes the hardware
>> counted in its "long" data type based byte counter.
> 
> Thanks for correcting me, Auke.
> 
> Should this counter be renamed to avoid someone else making this mistake
> in the future? Just a thought.

well, that would break tools that read this value. And for all of these stats
we can say that you should read our SDM's to figure out what they really
mean anyway, hence my caution to interpret the other value at first.

Auke
