From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6] net: Add batman-adv meshing protocol
Date: Wed, 01 Dec 2010 11:12:05 -0800 (PST)
Message-ID: <20101201.111205.28818479.davem@davemloft.net>
References: <201012011954.20275.sven.eckelmann@gmx.de>
	<20101201.105615.48506929.davem@davemloft.net>
	<201012012004.34356.sven.eckelmann@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: sven.eckelmann@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53717
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753890Ab0LATLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:11:39 -0500
In-Reply-To: <201012012004.34356.sven.eckelmann@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven.eckelmann@gmx.de>
Date: Wed, 1 Dec 2010 20:04:33 +0100

> David Miller wrote:
>> From: Sven Eckelmann <sven.eckelmann@gmx.de>
>> Date: Wed, 1 Dec 2010 19:54:19 +0100
>> 
>> > Do you have any more possible duplication you have in your mind right
>> > now?
>> 
>> The hashing code, for the third time.
> 
> And I asked in the past about the removal of the hashing stuff without any 
> reaction. So, we removed most of it. resize and iterate will be dropped too. 
> So, is it a problem to have a hash_find, hash_remove, hash_add? These were 
> created to reduce duplicated code and not to create a complete new dynamic 
> datastructure (which it isn't... it is just the usual hlist stuff)

Ok, fair enough.
