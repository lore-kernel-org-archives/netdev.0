From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: sky2 hangs
Date: Fri, 2 Feb 2007 07:27:22 +0100
Message-ID: <20070202062722.GZ13130@cip.informatik.uni-erlangen.de>
References: <20070201185532.GL13130@cip.informatik.uni-erlangen.de> <42007.80.98.159.250.1170369983.squirrel@www.hunhost.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Fagyal Csongor <concept@conceptonline.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui03.informatik.uni-erlangen.de ([131.188.30.103]:55392 "EHLO
	faui03.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423135AbXBBG1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 01:27:23 -0500
Content-Disposition: inline
In-Reply-To: <42007.80.98.159.250.1170369983.squirrel@www.hunhost.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Fagyal,

> - a previously suggested fix - passing idle=poll to the kernel - did not
> work for me at the end

same for me. I tried the two module parameters and the kernel parameter:

pci=nomsi sky2.disable_msi=1 sky2.idle_timeout=1000

> - the locks I have happen very periodically (somewhere around every 22-28
> hours), as if the chip would die after a given amount of data transferred;
> I know this looks stupid but I thought I might mention it

I had a dedicated server with sky2 which had the same symptoms but I
disabled the onboard sky2 to and added a e100. On my mac mini I can
reproduce it nearly immediately. Just have to scp a kernel tar tree over
and it hangs.

> - unloading the sky2 module totally freezes the computer for me

For me it works pretty good.

        Thomas
