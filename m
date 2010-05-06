From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH (v4)] bridge: update sysfs link names if port device
 names have changed
Date: Thu, 6 May 2010 12:40:38 -0700
Message-ID: <20100506124038.1b9849c7@nehalam>
References: <4BE30B3D.9000600@simon.arlott.org.uk>
	<4BE31218.6010709@simon.arlott.org.uk>
	<20100506121107.1868ad07@nehalam>
	<4BE31A67.4090007@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43796 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756548Ab0EFTlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 15:41:32 -0400
In-Reply-To: <4BE31A67.4090007@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 May 2010 20:37:11 +0100
Simon Arlott <simon@fire.lp0.eu> wrote:

> Links for each port are created in sysfs using the device
> name, but this could be changed after being added to the
> bridge.
> 
> As well as being unable to remove interfaces after this
> occurs (because userspace tools don't recognise the new
> name, and the kernel won't recognise the old name), adding
> another interface with the old name to the bridge will
> cause an error trying to create the sysfs link.
> 
> This fixes the problem by listening for NETDEV_CHANGENAME
> notifications and renaming the link.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=12743
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

Looks good
Acked-by: Stephen Hemminger <shemminger@vyatta.com>


-- 
