From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 2/6] smsc911x: add dynamic bus configuration
Date: Sun, 23 Nov 2008 13:39:05 +0000
Message-ID: <OF7747D767.14F5C717-ON8025750A.004A27CB-8025750A.004B0FA5@smsc.com>
References: <1225977010.16885.14.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: ian.saturley@smsc.com, Catalin Marinas <catalin.marinas@arm.com>,
	netdev@vger.kernel.org, jeff@garzik.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:4092 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757919AbYKWNkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 08:40:14 -0500
In-Reply-To: <1225977010.16885.14.camel@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Catalin Marinas <catalin.marinas@arm.com> wrote on 06/11/2008 13:10:10:
> > Convert the driver to select 16-bit or 32-bit bus access at runtime,
> > at a small performance cost.
> > 
> > Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> I tested it on the RealView platforms and works OK (can't tell about the
> other platforms).

Could you please apply the second patch in this set  to net-next (Jeff 
applied the first, the others are listed as "awaiting upstream" in 
patchwork), as all the later platform-dependant patches in the set require 
it.

Should I push the sh arch-dependant patches (3-5) via the sh tree, or does 
it make more sense to include them here as they depend on patches 1-2?

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

