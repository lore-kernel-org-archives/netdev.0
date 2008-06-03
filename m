From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Wed, 04 Jun 2008 01:23:24 +0200
Message-ID: <4845D26C.1030005@trash.net>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl> <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net> <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl> <484542B5.4070401@trash.net> <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl> <48458D59.5030101@trash.net> <Pine.LNX.4.64.0806032036070.3438@bizon.gios.gov.pl> <4845A963.2050208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jarek Poplawski <jarkao2@gmail.com>,
	netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54416 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbYFCXX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:23:26 -0400
In-Reply-To: <4845A963.2050208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Krzysztof Oledzki wrote:
>>
>>> I'm neither opposed (as long as we don't add CONFIG options for
>>> this) nor in favour - people using fixed applications won't notice,
>>> and for other people it substitutes undesired behaviour by more
>>> predictable undesirable behaviour,
>>
>> Exactly,
>>
>>> which is at least no loss :)
>>
>> OK, so I assume it is a very weak ack-by? ;)
> 
> Its a Not-NACKed-by: Patrick McHardy <kaber@trash.net> :)


I'll upgrade that to a full ACK - the predictability allows
to use the new features in combination with legacy apps and
avoid any trouble if done carefully. There is some small risk
of new breakage, but things probably won't work as expected
anyway.

Thanks Krzysztof.
