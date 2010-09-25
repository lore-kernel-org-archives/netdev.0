From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] de2104x: disable autonegotiation on broken hardware
Date: Fri, 24 Sep 2010 22:41:08 -0700 (PDT)
Message-ID: <20100924.224108.02278517.davem@davemloft.net>
References: <201009232259.20261.linux@rainbow-software.org>
	<AANLkTikwXyr4pH5rqkoXpiYvkvpLc7s8tq-EwmM1+r7m@mail.gmail.com>
	<201009232318.11541.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754213Ab0IYFks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 01:40:48 -0400
In-Reply-To: <201009232318.11541.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ondrej Zary <linux@rainbow-software.org>
Date: Thu, 23 Sep 2010 23:18:08 +0200

> On Thursday 23 September 2010 23:03:13 Jeff Garzik wrote:
>> On Thu, Sep 23, 2010 at 4:59 PM, Ondrej Zary <linux@rainbow-software.org> 
> wrote:
>> > At least on older 21041-AA chips (mine is rev. 11), TP duplex
>> > autonegotiation causes the card not to work at all (link is up but no
>> > packets are transmitted).
>> >
>> > de4x5 disables autonegotiation completely. But it seems to work on newer
>> > (21041-PA rev. 21) so disable it only on rev<20 chips.
>> >
>> > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
...
>> Interesting...  I never knew about that quirk.
> 
> This errata document says that autonegotiation is somehow broken but it does 
> not specify it further:
> http://ftp.nluug.nl/ftp/ftp/pub/os/NetBSD/misc/dec-docs/ec-qd2ma-te.ps.gz

Applied, thanks guys!
