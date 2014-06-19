From: "David J. Haines" <djhaines@gmx.com>
Subject: Documentation Bug Report (ping(8))
Date: Thu, 19 Jun 2014 10:33:26 -0400
Message-ID: <20140619143326.GA12090@aludra.phillips-angley.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:62132 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756624AbaFSOda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2014 10:33:30 -0400
Received: from aludra.phillips-angley.com ([173.162.240.62]) by mail.gmx.com
 (mrgmxus002) with ESMTPSA (Nemesis) id 0Le5Kk-1WN9Rl09Iy-00psg4 for
 <netdev@vger.kernel.org>; Thu, 19 Jun 2014 16:33:29 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

It appears that the manpage for ping(8) isn't being compiled correctly
as in the options section, it reads:

...
-B Do not allow ping to change source address of probes. The address is
bound to
one selected when ping starts.

Stop after sending count ECHO_REQUEST
...
-V Show version and exit.

Specify a timeout, in seconds, before
ping exits regardless of how many packets have been sent
...

When it should have "-c" and "-w" before "Stop" and "Specify,"
respectively. I don't really read SGML, but it appears that the option
to include the missing parameters simply isn't enabled as part of the
build process.

Thanks,

-- 
David J. Haines
djhaines@gmx.com
0xAFB3D16D - F929 270F B7C3 78AE A741  434F A7C6 F264 AFB3 D16C
