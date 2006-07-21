From: Olaf Hering <olh@suse.de>
Subject: incorrect usage of UTS_RELEASE in bcm43xx_get_drvinfo
Date: Fri, 21 Jul 2006 20:59:45 +0200
Message-ID: <20060721185945.GA7611@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:6567 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751105AbWGUS7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 14:59:55 -0400
To: Jason Lunz <lunz@falooley.org>, netdev@vger.kernel.org,
	mb@bu3sch.de
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


bcm43xx_get_drvinfo in 2.6.18-rc2 unfortunately uses UTS_RELEASE as
driver version. I think this specific info can be obtained by other
ways.
Can you give bcm43xx a real version number and provide it via the
ethtool ioctl?
It will trigger a rebuild if the uname -r of the kernel to build
changes.
