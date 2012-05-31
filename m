From: Dave Jones <davej@redhat.com>
Subject: r8169 vpd r/w failed
Date: Thu, 31 May 2012 13:41:26 -0400
Message-ID: <20120531174126.GA4189@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17197 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879Ab2EaSKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2012 14:10:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois,
 We occasionally see reports from r8169 where it seems to hang
reading vpd data from the NIC. The printk in drivers/pci/
suggests it's likely a firmware bug on the device, and recommends the user
contact the vendor for an update (does Realtek even do firmware updates?)

Is this as the message suggests a firmware bug, or should r8169 be
avoiding trying to read vpd ?

https://bugzilla.redhat.com/show_bug.cgi?id=827137 is one example.

thanks,

	Dave
