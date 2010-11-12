From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: don't remove address state on ifdown
 if the address is being kept
Date: Fri, 12 Nov 2010 13:45:19 -0800 (PST)
Message-ID: <20101112.134519.52180921.davem@davemloft.net>
References: <AANLkTimyqFoUvjQM_qLS2YeVmJQ_6-LJc6KfLVE-mzH3@mail.gmail.com>
	<AANLkTimLicmgC3BptZvXGoA0aN6-cFJtRG3DpqJ3NTpJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, brian.haley@hp.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932627Ab0KLVoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 16:44:55 -0500
In-Reply-To: <AANLkTimLicmgC3BptZvXGoA0aN6-cFJtRG3DpqJ3NTpJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Wed, 27 Oct 2010 23:45:17 -0700

> On Wed, Oct 27, 2010 at 9:16 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
>> Fix it so that none of this state is updated if the address is being kept on the interface.
> 
> Or, since the logic of the patched code is a little hard to follow,
> here's an alternative patch against 2.6.36. I think it does exactly
> the same as the previous patch, but it moves things around to make the
> result more readable.
> 
> Tested: Added a statically configured IPv6 address to an interface,
> started ping, brought link down, brought link up again. When link came
> up ping kept on going and "ip -6 maddr" showed that the host was still
> subscribed to there
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Ok, this looks good, applied.

Thanks for your patience.
