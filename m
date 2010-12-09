From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: biosdevname v0.3.3
Date: Thu, 9 Dec 2010 15:51:14 -0600
Message-ID: <20101209215114.GA30075@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	"K, Narendra" <Narendra_K@Dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	Co
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:58259 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757418Ab0LIVvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 16:51:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

biosdevname, now version 0.3.3.

I re-added the PCI IRQ Routing Table lookup code.  This is used as a
fallback, in the event system BIOS doesn't provide index and label
information in a way we can get at via sysfs, or via reading SMBIOS
directly.  This is necessary as quite a few systems I want to
have this feature on do not yet expose this info via SMBIOS, yet the
values in $PIR are perfectly usable for this purpose.


Grab it here:
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.3.tar.gz
http://linux.dell.com/files/biosdevname/permalink/biosdevname-0.3.3.tar.gz.sign
git://linux.dell.com/biosdevname.git

I built this today for Fedora rawhide (will be 15), and I encourage
other distributions to pick it up as well.

shortlog:

Matt Domsch (5):
      add back in PCI IRQ Routing Table lookups, as a fallback
      add in the pirq.[ch] files too
      sort PCI device list, set embedded_index better, use PIRQ info
      as a last resort
      remove Dell-specific code from make_release.sh
      bump version


Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
