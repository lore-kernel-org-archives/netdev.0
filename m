From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: Fix kfree NULL pointer
Date: Tue, 07 Sep 2010 22:53:27 -0700 (PDT)
Message-ID: <20100907.225327.229757822.davem@davemloft.net>
References: <AANLkTikp0m8cQYfEBHP_E8XpGZqdMj6Cr4M=aWCnei=X@mail.gmail.com>
	<1283923185.2634.772.camel@edumazet-laptop>
	<AANLkTim+=vj+k3=1hzT3=J4ssOopp5Eq=g+DHis=pZFN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, johannes.berg@intel.com,
	ebiederm@xmission.com, adobriyan@openvz.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bookjovi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46577
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751570Ab0IHFxJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 01:53:09 -0400
In-Reply-To: <AANLkTim+=vj+k3=1hzT3=J4ssOopp5Eq=g+DHis=pZFN@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: jovi zhang <bookjovi@gmail.com>
Date: Wed, 8 Sep 2010 13:33:28 +0800

> =A0Also I check kfree usage in other code, I havn't find any kfree(NU=
LL) usage.

You aren't looking hard enough.

Please leave this code alone, it's functionally correct and fine.
