From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Tue, 15 Mar 2005 07:55:51 -0800
Message-ID: <200503151555.j2FFtqDD019050@guinness.s2io.com>
References: <200503151507.j2FF7sDD011131@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid@neterion.com>, <jgarzik@pobox.com>,
        "'Andi Kleen'" <ak@muc.de>
To: "'Leonid Grossman'" <leonid.grossman@neterion.com>, <alex@neterion.com>,
        <davem@davemloft.net>
In-Reply-To: <200503151507.j2FF7sDD011131@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> 
> > Leonid Grossman writes:
> It's not the best maintenance option (both for us and arguably, even for a
> non-primary-author kernel hackers) but it's workable.

The statement about non-primary-author kernel hacker interests needs some
clarification, before people started to throw things at me. 
This is the last argument before I shut up, I promise :-)

Arguably, a hacker will be much more interested in changing the non-HAL part
of a driver. This part of the code has to look and feel the same as any
other Linux net driver. If it doesn't, then we've done a poor job and need
to go back.

In our experience, the vast majority of code fixes and new features in the
HAL code comes from our team (hey, we planted all these bugs to begin with
:-)), and to a much lesser extend from other OS developers, and only then
from Linux community. 

This is normal - for example, if Large Receive Offload that was discussed
earlier is to be done, I'd expect a hacker to focus on the kernel changes
and generic driver changes (to make a feature common to all net driver that
want it), and a Neterion developer to focus on the hw-specific changes. 

There will be nothing wrong if they trade places, but the first scenario
seems more likely.

So, for a hacker it's harder to understand HAL part of the code - but then
he is not doing the bulk of the maintenance of the ASIC -specific code that
he's arguably least interested in maintaining...
Leonid
