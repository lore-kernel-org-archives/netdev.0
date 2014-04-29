From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping transmit
	ring on timeout
Date: Tue, 29 Apr 2014 15:15:27 +0100
Message-ID: <20140429141527.GZ26756@n2100.arm.linux.org.uk>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com> <1398773350-7293-5-git-send-email-Frank.Li@freescale.com> <063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com> <CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Frank Li' <lznuaa@gmail.com>, Frank Li <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:57430 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933140AbaD2OQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 10:16:40 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 02:01:54PM +0000, David Laight wrote:
> From: Frank ...
> > > You probably want the read and write indexes as well.
> > 
> >                      bdp == fep->cur_tx ? 'S' : ' ',
> >                      bdp == fep->dirty_tx ? 'H' : ' ',
> > 
> > Above code already print read and write index. 'S', 'H'
> 
> Gah I must be asleep!
> Something made be think that was to do with the ring ownership bit!

Err, what's going on... this is my patch.  If it's been submitted by
others, why wasn't its submission at least Cc'd to me?

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
