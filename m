From: "Ed Swierk" <eswierk@arastra.com>
Subject: Re: [patch 02/10] forcedeth: power down phy when interface is down
Date: Thu, 13 Dec 2007 16:53:58 -0800
Message-ID: <e6c711510712131653p3c871115r6e9cf33e0c984772@mail.gmail.com>
References: <200712140002.lBE02qo1025508@imap1.linux-foundation.org>
	 <F72FA20C31DD4F4C997B91C5B3690A091A990D@hqemmail07.nvidia.com>
	 <20071213163046.c2e9d340.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ayaz Abdulla" <AAbdulla@nvidia.com>, jeff@garzik.org,
	netdev@vger.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:64016 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240AbXLNAx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:53:59 -0500
Received: by rv-out-0910.google.com with SMTP id k20so742270rvb.1
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 16:53:58 -0800 (PST)
In-Reply-To: <20071213163046.c2e9d340.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> Does this patch actually fix any observeable problem?

Without the patch, ifconfig down leaves the physical link up, which
confuses datacenter users who expect the link lights both on the NIC
and the switch to go out when they bring an interface down.

Furthermore, even though the phy is powered on, autonegotiation stops
working, so a normally gigabit link might suddenly become 100 Mbit
half-duplex when the interface goes down, and become gigabit when it
comes up again.

--Ed
