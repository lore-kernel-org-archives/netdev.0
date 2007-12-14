From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 02/10] forcedeth: power down phy when interface is down
Date: Thu, 13 Dec 2007 17:07:21 -0800
Message-ID: <20071213170721.e71ff79f.akpm@linux-foundation.org>
References: <200712140002.lBE02qo1025508@imap1.linux-foundation.org>
	<F72FA20C31DD4F4C997B91C5B3690A091A990D@hqemmail07.nvidia.com>
	<20071213163046.c2e9d340.akpm@linux-foundation.org>
	<e6c711510712131653p3c871115r6e9cf33e0c984772@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: AAbdulla@nvidia.com, jeff@garzik.org, netdev@vger.kernel.org
To: "Ed Swierk" <eswierk@arastra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49834 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751628AbXLNBHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 20:07:30 -0500
In-Reply-To: <e6c711510712131653p3c871115r6e9cf33e0c984772@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2007 16:53:58 -0800
"Ed Swierk" <eswierk@arastra.com> wrote:

> On 12/13/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > Does this patch actually fix any observeable problem?
> 
> Without the patch, ifconfig down leaves the physical link up, which
> confuses datacenter users who expect the link lights both on the NIC
> and the switch to go out when they bring an interface down.
> 
> Furthermore, even though the phy is powered on, autonegotiation stops
> working, so a normally gigabit link might suddenly become 100 Mbit
> half-duplex when the interface goes down, and become gigabit when it
> comes up again.
> 

OK, thanks, I added that text to the changelog along with Ayaz's objection
and shall continue to bug people with it until we have a fix merged.  
