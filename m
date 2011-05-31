From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Tue, 31 May 2011 06:05:05 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1105310602360.13754@uplift.swm.pp.se>
References: <4DE44218.4070306@krellan.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Josh Lehan <linux@krellan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:34633 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762Ab1EaEFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 00:05:07 -0400
In-Reply-To: <4DE44218.4070306@krellan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 May 2011, Josh Lehan wrote:

> Hello.  I looked, but could not find an answer.  Is there already an
> ioctl() or something like that in Linux, that would allow a userspace
> TCP socket to skip past a lost packet?

The basic operation of TCP is that it delivers a character stream to the 
application. That requires TCP to make sure everything is in order and 
nothing is missing.

If you want to do something else, you have to choose another protocol.

> Is there a way for a userspace program to prevent this needless stall?

That's like saying your body has all that needless blood.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
