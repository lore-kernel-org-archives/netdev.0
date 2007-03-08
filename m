From: Pavel Roskin <proski@gnu.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 08 Mar 2007 17:49:48 -0500
Message-ID: <1173394188.26190.24.camel@dv>
References: <1173144447.15891.93.camel@johannes.berg>
	 <20070306171316.GA19669@bougret.hpl.hp.com>
	 <200703061943.07350.mb@bu3sch.de>
	 <20070307020310.GA20466@bougret.hpl.hp.com>
	 <1173364747.14001.7.camel@johannes.berg>
	 <20070308184954.GA24485@bougret.hpl.hp.com>
	 <1173382042.3248.63.camel@johannes.berg>
	 <20070308193412.GG23040@devicescape.com>
	 <1173382802.3248.68.camel@johannes.berg>
	 <20070308221128.GA24884@bougret.hpl.hp.com>
	 <20070308141756.efdfd6da.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, Johannes Berg <johannes@sipsolutions.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Michael Buesch <mb@bu3sch.de>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Dan Williams <dcbw@redhat.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:58745 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030846AbXCHWt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 17:49:58 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1HPRPA-0004u4-8R
	for netdev@vger.kernel.org; Thu, 08 Mar 2007 17:48:12 -0500
In-Reply-To: <20070308141756.efdfd6da.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-08 at 14:17 -0800, Randy Dunlap wrote:
> I think that this is not actually an option since
> powerpc64 is all 32-bit userspace.
> Maybe some other arch-es are like this also (?).

I think all other architectures except x86_64 and maybe ia64 would
prefer to stay 32-bit for performance reasons alone.  As for x86_64 and
ia64, there is another incentive, namely compatibility with x86, which
matters if proprietary software is involved.  Finally, using 32-bit
userspace could cut memory consumption, which is important for some
uses.

Switching 32-bit systems to a 64-bit kernel shouldn't be a big deal.  It
should be transparent, just like enabling an option to support 4
gigabytes of memory or 64-bit PCI resources.

32-bit distributions should have an option to install a 64-bit kernel,
just like it's possible to install a kernel optimized for 586 CPU.  A
Live CD could benefit from 64-bit kernel because it would allow users to
chroot to their 64-bit distro installation and repair it, without having
to provide 64-bit userspace on the CD.

I think the reason 32-bit userspace on 64-bit kernel is not widespread
is precisely because of such incompatibilities as the one we are
discussing.  The need for proper support will grow as laptops with over
1 gigabyte of memory become a commonplace.

I believe breaking the "u32/k64" compatibility is not an option. I would
prefer the option two, the changeover.  I don't think wireless
extensions (or at least the compatible kernel API) should go away soon.

-- 
Regards,
Pavel Roskin

