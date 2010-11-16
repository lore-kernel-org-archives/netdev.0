From: Nikola Ciprich <extmaillist@linuxbox.cz>
Subject: 2.6.37-rc2 after KVM shutdown - unregister_netdevice: waiting for
	vmtst01eth0 to become free. Usage count = 1
Date: Tue, 16 Nov 2010 09:41:48 +0100
Message-ID: <20101116084148.GA3781@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nikola.ciprich@linuxbox.cz,
	Linux kernel list <linux-kernel@vger.kernel.org>
To: KVM list <kvm@vger.kernel.org>,
	netdev list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:52090 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757284Ab0KPInX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Nov 2010 03:43:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I just tried running KVM on 2.6.37-rc2 host, and when trying to shutdown guest, it
got to unterruptible state (D) and I'm getting lots of following messages:
[ 1269.392009] unregister_netdevice: waiting for vmtst01eth0 to become free. Usage count = 1
So I just want to report..
n.


-- 
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 01 Ostrava

tel.:   +420 596 603 142
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------
