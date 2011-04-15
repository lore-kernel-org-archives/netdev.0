From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: Feature request: "inverted" ping -a (beep on failure)
Date: Fri, 15 Apr 2011 12:49:37 -0700
Message-ID: <20110415124937.6e746646.rdunlap@xenotime.net>
References: <201104152135.33171@tux.boltz.de.vu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christian Boltz <netdev-vger-kernel.org@cboltz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpoproxy1-pub.bluehost.com ([69.89.21.11]:52709 "HELO
	cpoproxy1-pub.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751276Ab1DOTtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 15:49:40 -0400
In-Reply-To: <201104152135.33171@tux.boltz.de.vu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Apr 2011 21:35:32 +0200 Christian Boltz wrote:

> Hello,
> 
> ping -a (beep on ping success) is a quite useful command, but it can be 
> annoying.
> 
> I'd like to have the exact opposite of it: beep when pinging fails.
> 
> I understand that this is slightly difficult because "ping success" is 
> easier to detect (incoming package) than "ping failure" (no incoming 
> package or firewall reject) - my proposal is to have a timeout for every 
> package (if no reply package comes in) and beep if no reply is seen 
> after the timeout is over.
> 
> For the timeout, the -W option could be used. The default timeout seems 
> to be 10 seconds, which is OK.
> 
> Usecase / why this would be useful for me:
> Basically for server monitoring. The exact usecase is that I have rented 
> a "root server" and asked the hoster to exchange a broken harddisk.
> With the "inverted" ping -a, it would be easy to notice when they switch 
> off the server to replace the disk.
> 
> Please consider this feature for the next version of ping ;-)
> 
> 
> (The iputils homepage does not list any bugtracker or similar, therefore 
> I'm asking here.)

Couldn't you look for exit code (status) 1 and then do a bell/beep
(or play a sound file :)?

Or do you want ping to beep and then continue running?

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
