From: Rodolfo Giometti <giometti@enneenne.com>
Subject: Re: Generic netlink interface help
Date: Thu, 24 May 2007 11:56:58 +0200
Message-ID: <20070524095654.GA21180@enneenne.com>
References: <20070524085956.GP7089@enneenne.com> <84po8XY4.1179999810.5490870.samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-174-11-161.f5.ngi.it ([81.174.11.161]:36125 "EHLO
	mail.enneenne.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755802AbXEXJ4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 05:56:14 -0400
Content-Disposition: inline
In-Reply-To: <84po8XY4.1179999810.5490870.samuel@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 24, 2007 at 09:43:30AM -0000, Samuel Ortiz wrote:

> You could look at Johannes Berg 802.11 generic netlink implementation for
> a good example (net/wireless/nl80211.c in John Linville's tree):
> http://git.kernel.org/?p=linux/kernel/git/linville/wireless-dev.git;a=blob;f=net/wireless/nl80211.c;h=d6a44a386c2b86b81514b08d3c9b324dd2c7d229;hb=HEAD

Thanks, I'll take a look to it!

> You probably want to use the libnl library. The latest SVN code has
> support for generic netlink:
> http://people.suug.ch/~tgr/libnl/

Regarding this issue I'd like to know if could be possible to avoid
using this library... my LinuxPPS support is strictly relate with NTPD
which doesn't use such library. It could be possible still using
simple syscalls to access this new layer as for the old API?

Thanks,

Rodolfo

-- 

GNU/Linux Solutions                  e-mail:    giometti@enneenne.com
Linux Device Driver                             giometti@gnudd.com
Embedded Systems                     		giometti@linux.it
UNIX programming                     phone:     +39 349 2432127
