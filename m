From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH net-next] wan: dlci/sdla transmit return dehacking
Date: Fri, 04 Sep 2009 20:48:50 +0200
Message-ID: <m31vmmk0kt.fsf@intrepid.localdomain>
References: <20090904143439.c44f61ee.sfr@canb.auug.org.au>
	<20090903.213548.46609322.davem@davemloft.net>
	<20090904083346.43885303@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090904083346.43885303@nehalam> (Stephen Hemminger's message of
	"Fri, 4 Sep 2009 08:33:46 -0700")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@vyatta.com> writes:

> This is a brute force removal of the wierd slave interface done for
> DLCI -> SDLA transmit. Before it was using non-standard return values
> and freeing skb in caller. This changes it to using normal return
> values, and freeing in the callee. Luckly only one driver pair was
> doing this. Not tested on real hardware, in fact I wonder if this
> driver pair is even being used by any users.

The only hardware which seems to be driven by dlci.c is sdla.c =
old Sangoma ISA cards.

Sangoma seems to maintain their own drivers for their hw (including
these ISA cards).

Are the in-kernel drivers functional after all those years? I don't
know.
-- 
Krzysztof Halasa
