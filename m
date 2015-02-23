From: Alexander Clouter <alex@digriz.org.uk>
Subject: Re: forwarding IPv6 LL packets, bug?
Date: Mon, 23 Feb 2015 08:56:12 +0000
Message-ID: <20150223085612.GB22890@stevemcqueen.digriz.org.uk>
References: <20150222164341.GD28830@stevemcqueen.digriz.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from marmot.wormnet.eu ([188.246.204.87]:53347 "EHLO
	marmot.wormnet.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbbBWJMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:12:35 -0500
Received: from [2001:a08:a260:a:ed7f:219:681f:287] (helo=localhost)
	by marmot.wormnet.eu with esmtpsa (TLSv1.2:DHE-RSA-AES128-SHA:128)
	(Exim 4.84)
	(envelope-from <alex@digriz.org.uk>)
	id 1YPooH-0008BW-Dh
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 08:56:13 +0000
Content-Disposition: inline
In-Reply-To: <20150222164341.GD28830@stevemcqueen.digriz.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 22, 2015 at 04:43:41PM +0000, Alexander Clouter wrote:
>
> [snipped]
>
>So I cracked out the source code and found where I think the problem 
>might be, net/ipv6/ip6_output.c:ip6_forward().  I think the else 
>block tied to the if clause handling redirect generation should be 
>move above the block alternative and made non-conditional?  Something 
>like the attachment?

Patch should probably additionally look at the destination address?

-- 
Alexander Clouter
.sigmonster says:             BOFH excuse #227:
                               Fatal error right in front of screen
