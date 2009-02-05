From: Guido =?iso-8859-1?Q?G=FCnther?= <agx@sigxcpu.org>
Subject: Re: Allow group ownership of TUN/TAP devices.
Date: Thu, 5 Feb 2009 11:54:57 +0100
Message-ID: <20090205105456.GA26440@bogon.ms20.nix>
References: <498700CD.2030403@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-87-79-238-240.netcologne.de ([87.79.238.240]:53009 "EHLO
	honk.sigxcpu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbZBELDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 06:03:43 -0500
Content-Disposition: inline
In-Reply-To: <498700CD.2030403@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2009 at 05:18:53PM +0300, Michael Tokarev wrote:
[..snip..] 
> My first attempt - pretty obvious when I saw -g option of tunctl - is
> to add group ownership for the tun device and add a supplementary group
> to each user (their primary group should be different).  But that fails,
> since kernel only checks for egid, not any other group ids.
Since others tripped on this it might make sense to change it to also
check supplementary groups. However I don't think changing the existing
syscall is an option since it might allow users to access tun/tap
devices on existing systems that weren't allowed to do so before (which
might be a security problem).
Cheers,
 -- Guido
