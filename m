From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: What ixgbe devices support HWTSTAMP_FILTER_ALL for hardware time
 stamping?
Date: Sun, 15 May 2016 09:51:30 +0200
Message-ID: <20160515075129.GA2581@netboy>
References: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu>
 <20160514073002.GA2053@netboy>
 <4AAA3CE1-B137-4AC1-AB85-B4690E8E3E12@alum.mit.edu>
 <20160514202653.GA6529@netboy>
 <B32E7BAF-090F-4D9F-A519-B96AF2FD0EF0@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35777 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbcEOHvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 03:51:41 -0400
Received: by mail-wm0-f50.google.com with SMTP id e201so66959271wme.0
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 00:51:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <B32E7BAF-090F-4D9F-A519-B96AF2FD0EF0@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2016 at 07:11:50PM -0700, Guy Harris wrote:
> It could do a combination of #2 and #1, where "offers all
> possibilities" is replaced by "opens the adapter, tries each of the
> possibilities, and offers the ones that don't fail" - but, other
> than the current bugs with ETHTOOL_GET_TS_INFO, I don't see any
> advantage to doing only #1, rather than trying #2, perhaps with some
> special-casing to work around the bugs in question, and only falling
> back on actually trying to set the options if we can't ask about
> them.

Right.

Regarding the drivers you found, even if you can't patch them
yourself, please write the maintainers directly with me and netdev on
CC in order to bring attention to the bugs.

The get_maintainer.pl script can help identify the maintainers.

Thanks,
Richard
