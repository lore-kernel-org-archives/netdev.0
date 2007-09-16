From: James Chapman <jchapman@katalix.com>
Subject: Re: e1000 driver and samba
Date: Sun, 16 Sep 2007 17:24:15 +0100
Message-ID: <46ED58AF.1070000@katalix.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com> <46EAC25B.2060404@intel.com> <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com> <46EAF644.1040006@intel.com> <46EC1A00.2000304@katalix.com> <46EC2D5A.7080504@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: L F <lfabio.linux@gmail.com>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:40297 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbXIPQYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Sep 2007 12:24:18 -0400
In-Reply-To: <46EC2D5A.7080504@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> James Chapman wrote:
>> Kok, Auke wrote:

>>>>      rx_long_byte_count: 34124849453
>>
>> Are these long frames expected in your network? What is the MTU of the 
>> transmitting clients? Perhaps this might explain why reads work 
>> (because data is coming from the Linux box so the packets have smaller 
>> MTU) while writes cause delays or packet loss because the clients are 
>> sending long frames which are getting fragmented?
> 
> those are not "long frames" but the number of bytes the hardware counted 
> in its "long" data type based byte counter.

Thanks for correcting me, Auke.

Should this counter be renamed to avoid someone else making this mistake 
in the future? Just a thought.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

