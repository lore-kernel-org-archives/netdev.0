From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11 4/8] tg3: Add msi test
Date: Tue, 22 Mar 2005 18:50:36 -0500
Message-ID: <4240AF4C.9030109@pobox.com>
References: <B1508D50A0692F42B217C22C02D84972020F3E2E@NT-IRVA-0741.brcm.ad.broadcom.com>	<424098E2.6090007@pobox.com>	<20050322141714.4515258f.davem@davemloft.net>	<42409BA4.3090302@pobox.com> <20050322154030.310e85c1.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050322154030.310e85c1.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Just because it's what we've been doing doesn't mean it's the
> best solution in this case.
> 
> If you hope users will just report this stuff, most of them won't.
> They'll say Linux doesn't work on my computer and I have real life
> stuff to take care of so I'll install freebsd or windows or a different
> networking card and get on with life.
> 
> Eventually, say over a year or so, the database of bad chipsets will
> get built with your scheme, but to much hardship and pain to users.


What do you think will happen for all the other MSI drivers/hardware out 
there?

Adding this test to tg3 simply means another piece of hardware doesn't 
work.  The problem disappears for -you-, but not the user.

You're just pushing the pain around, for the -few- -early- systems with 
problems.

Sorry, I still disagree.  We need to think about how to handle this 
situation for -all- drivers and -all- users, not just tg3.

	Jeff
