From: Ben Greear <greearb@candelatech.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 00:18:31 -0700
Message-ID: <44755A47.3030405@candelatech.com>
References: <20060523.182217.59656237.davem@davemloft.net>	<447412CA.50303@ipom.com> <4474A489.4080308@garzik.org>	<20060524185644.GF22881@ipom.com> <4474AE92.3030501@garzik.org>	<20060524191442.GG22881@ipom.com> <1148501433.5325.52.camel@jzny2> <20060524204800.GH22881@ipom.com> <4474CA66.5020401@hp.com> <4474CBAA.4040307@candelatech.com> <44753A3B.5010204@ipom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:35477 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S965062AbWEYHT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 03:19:26 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <44753A3B.5010204@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phil Dibowitz wrote:

> As for the clearing, in this case, the clearing is done by a command to
> the hardware - and I believe the hardware does that atomically. However,
> I could certainly add a spinlock around it if someone sees a need.

No, because then you'd also have to add the spin-lock in the hot path
to keep rx/tx threads from accessing counters at the same time.  There is no
way a patch that hurts performance like this will be accepted, but I'm
still hopeful that a patch with zero or very near zero performance impact
will be accepted.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

