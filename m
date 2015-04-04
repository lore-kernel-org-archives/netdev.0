From: Rick Jones <rick.jones2@hp.com>
Subject: VxLAN system wedge in 4.0.0-rc5+ from davem net-next?
Date: Fri, 03 Apr 2015 17:11:12 -0700
Message-ID: <551F2C20.1060908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:58993 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbbDDALO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 20:11:14 -0400
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com [15.240.92.66])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 9972B602A9
	for <netdev@vger.kernel.org>; Sat,  4 Apr 2015 00:11:13 +0000 (UTC)
Received: from g4t3433.houston.hp.com (g4t3433.houston.hp.com [16.210.25.219])
	by g9t5008.houston.hp.com (Postfix) with ESMTP id D1331125
	for <netdev@vger.kernel.org>; Sat,  4 Apr 2015 00:11:12 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g4t3433.houston.hp.com (Postfix) with ESMTP id A1BAA8B
	for <netdev@vger.kernel.org>; Sat,  4 Apr 2015 00:11:12 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

I've been messing about with VxLAN with a pair of two socket systems 
with ixgbe-driven NICs (HP 560FLRs for the curious) and have noticed 
that with a kernel from a davem net-next tree I refreshed a couple days 
ago I can create the vlxan link, and ifconfig it, but once I start 
trying to push packets through it the system appears to hang and I have 
to reset it.

I went back to checkout v3.19 and tried that kernel and all was 
happiness and joy.  So, I started down the bisect path, but after the 
first iteration I ran into:

   INSTALL debian/headertmp/usr/include/asm/ (65 files)
parsechangelog/debian: warning:     debian/changelog(l2): found eof 
where expected first heading
parsechangelog/debian: error: fatal error occurred while parsing 
debian/changelog
dpkg-gencontrol: error: changelog parser 
/usr/lib/dpkg/parsechangelog/debian gave error exit status 255
scripts/package/Makefile:90: recipe for target 'deb-pkg' failed
make[1]: *** [deb-pkg] Error 255
Makefile:1238: recipe for target 'deb-pkg' failed
make: *** [deb-pkg] Error 2

Which I'm afraid goes beyond my knowledge of how to deal.  Does any of 
that - either the VxLAN or the build problem - sound familiar?

thanks,

rick jones
