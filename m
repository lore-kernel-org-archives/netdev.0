From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 02/10] forcedeth: power down phy when interface is down
Date: Thu, 13 Dec 2007 16:30:46 -0800
Message-ID: <20071213163046.c2e9d340.akpm@linux-foundation.org>
References: <200712140002.lBE02qo1025508@imap1.linux-foundation.org>
	<F72FA20C31DD4F4C997B91C5B3690A091A990D@hqemmail07.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, eswierk@arastra.com
To: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44480 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755839AbXLNAb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:31:27 -0500
In-Reply-To: <F72FA20C31DD4F4C997B91C5B3690A091A990D@hqemmail07.nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2007 16:11:55 -0800
"Ayaz Abdulla" <AAbdulla@nvidia.com> wrote:

> I would not include this patch until further testing is performed.
> NVIDIA MCP chips use 3rd party PHY vendors. By powering down the phy, it
> could have adverse affects on certain phys.
> 
> Ayaz
> 
> 
> -----Original Message-----
> From: akpm@linux-foundation.org [mailto:akpm@linux-foundation.org] 
> Sent: Thursday, December 13, 2007 4:03 PM
> To: jeff@garzik.org
> Cc: netdev@vger.kernel.org; akpm@linux-foundation.org;
> eswierk@arastra.com; Ayaz Abdulla
> Subject: [patch 02/10] forcedeth: power down phy when interface is down
> 
> 
> From: "Ed Swierk" <eswierk@arastra.com>
> 
> Bring the physical link down when the interface is down by placing the
> PHY
> in power-down state, unless WOL is enabled.  This mirrors the behavior
> of
> other drivers including e1000 and tg3.

Does this patch actually fix any observeable problem?
