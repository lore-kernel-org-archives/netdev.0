From: Rick Jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Mon, 24 Jan 2005 13:22:23 -0800
Message-ID: <41F5670F.4000209@hp.com>
References: <41F1516D.5010101@hp.com> <200501211358.53783.jdmason@us.ibm.com>	<41F163AD.5070400@hp.com>	<20050121124441.76cbbfb9.davem@davemloft.net>	<41F17B7E.2020002@hp.com>	<20050121141820.7d59a2d1.davem@davemloft.net>	<41F186A8.9030805@hp.com>	<20050121204948.034b2510.davem@davemloft.net>	<41F55B93.6040603@hp.com> <20050124124353.2f760e1a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050124124353.2f760e1a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Becuase we disable TSO on any packet loss whatsoever, we can predict
> exactly what the CWND will be at the time a packet is sent.

I'd heard someone else mention that, but wasn't sure. Now I know I guess.  I can 
see how that would simplify things considerably, although it may have some 
non-technical implications...

> When we take away that invariant, which we do want to do, we'll need
> to tweak how this works.

OK.  BTW, how "hard" is it to reference chunks of a big buffer and send them? 
Particularly in a situation where there is TSO which implies SG and CKO.

rick
