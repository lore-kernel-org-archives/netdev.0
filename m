From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/8] forcedeth: fix MAC address detection on network
 card (regression in 2.6.23)
Date: Wed, 21 Nov 2007 15:47:23 -0800
Message-ID: <20071121154723.34c5f647.akpm@linux-foundation.org>
References: <200711212302.lALN2sF8013655@imap1.linux-foundation.org>
	<F72FA20C31DD4F4C997B91C5B3690A091A9857@hqemmail07.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, michael.pyne@kdemail.net,
	stable@kernel.org
To: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46349 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752206AbXKUXrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:47:49 -0500
In-Reply-To: <F72FA20C31DD4F4C997B91C5B3690A091A9857@hqemmail07.nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Nov 2007 15:34:52 -0800
"Ayaz Abdulla" <AAbdulla@nvidia.com> wrote:

> The solution is to get the OEM to update their BIOS (instead of
> integrating this patch) since the MCP61 specs indicate that the MAC
> Address should be in correct order from BIOS.
> 
> By changing the feature DEV_HAS_CORRECT_MACADDR to all MCP61 boards, it
> could cause it to break on other OEM systems who have implemented it
> correctly.
> 

Getting an OEM to fix their BIOS isn't always a simple thing...

Perhaps Michael's change should be enabled by a module parameter for
those who happen to have the busted BIOS?

