From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Problems finding ethtool source
Date: Tue, 19 Feb 2013 21:18:54 +0000
Message-ID: <1361308734.2967.31.camel@bwh-desktop.uk.solarflarecom.com>
References: <51238D03020000680002CB63@gwia.alliedtelesyn.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>,
	chris packham <chris.packham@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11747 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758582Ab3BSVTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 16:19:15 -0500
In-Reply-To: <51238D03020000680002CB63@gwia.alliedtelesyn.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-19 at 14:32 +1300, chris packham wrote:
> Hi Ben,
> 
> Just writing to let you know about the trouble I had locating the source
> tarballs for ethtool.
> 
> I didn't have any particular problem I just wanted to make sure the
> version of ethtool we use on our embedded target was compatible with
> our kernel version.

You shouldn't see compatibility issues between differing ethtool and
kernel versions, as the ethtool ABI is intended to be stable.  (That's
not to say there aren't bugs.)  The ethtool version number is a rough
indicator that it can exercise the features implemented in the
corresponding kernel version.

> Being lazy I headed to google and searched for 
> "ethtool source" which took me to the sourceforge.net page with the
> older versions. I actually had to try pretty hard to find the 
> http://www.kernel.org/pub/software/network/ethtool/ page (eventually
> got there via debian.org). 

http://tinyurl.com/ethtool-home also works.

> Are you (or anyone on netdev) in contact with Jeff Garzik? If so could you
> ask for a link to the newer versions to be added to the sf.net page, I think
> that'd help others searching for the real upstream.

Jeff, would you mind adding a link to the current ethtool page in or
under the gkernel project description?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
