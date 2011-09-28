From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridging broken/unfriendly
Date: Wed, 28 Sep 2011 08:30:21 -0700
Message-ID: <20110928083021.2edf43a6@nehalam.linuxnetplumber.net>
References: <4E7E5976.1070200@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42435 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752938Ab1I1PaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 11:30:23 -0400
In-Reply-To: <4E7E5976.1070200@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 24 Sep 2011 18:28:06 -0400
Stephen Clark <sclark46@earthlink.net> wrote:

> Hi,
> 
> Is there some reason Linux bridging won't let the ip address be on
> one of the interfaces, like FreeBSD does, instead of the bridge device?
> 
> This makes it very difficult or impossible to remotely add the interface
> you are remoted in on to a bridge, or is there some sneaky way to
> do this without losing your connection?
> 

I would like to see a clean solution to setting up a bridge.
There was a patch that was never completed to allow migrating a ethernet
interface into a bridge. It is possible to do it with a script, by
dumping routes with ip command and replaying that into the bridge.
To really do it right (including neighbor table and iptables rules)
would be complex, especially considering the error cases.

Having looked at the FreeBSD code, that is not the answer. Trying to keep
a clean separation between IP and bridging is much better.
