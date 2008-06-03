From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 03 Jun 2008 20:28:41 +0200
Message-ID: <48458D59.5030101@trash.net>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl> <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net> <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl> <484542B5.4070401@trash.net> <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48079 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbYFCS2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 14:28:44 -0400
In-Reply-To: <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote:
> On Tue, 3 Jun 2008, Patrick McHardy wrote:
> 
>> I think the proper solution is what I wrote in the changelog
>> entry: fix userspace applications when using extended table
>> IDs.
> 
> It is unquestionably true, however it may take some time and people may 
> still use old version of such applications for whatsoever reasons.
> 
>> Your patch makes it more predictable, so I'm not completely
>> opposed, but still its just a workaround.
> 
> Indeed - it is a workaround but I believe we need it.

I'm neither opposed (as long as we don't add CONFIG options for
this) nor in favour - people using fixed applications won't notice,
and for other people it substitutes undesired behaviour by more
predictable undesirable behaviour, which is at least no loss :)
