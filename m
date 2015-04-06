From: Rick Jones <rick.jones2@hp.com>
Subject: Re: VxLAN system wedge in 4.0.0-rc5+ from davem net-next?
Date: Mon, 06 Apr 2015 10:32:17 -0700
Message-ID: <5522C321.40706@hp.com>
References: <551F2C20.1060908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:34528 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbbDFRcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 13:32:18 -0400
Received: from g4t3433.houston.hp.com (g4t3433.houston.hp.com [16.210.25.219])
	by g4t3427.houston.hp.com (Postfix) with ESMTP id F16127A
	for <netdev@vger.kernel.org>; Mon,  6 Apr 2015 17:32:17 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g4t3433.houston.hp.com (Postfix) with ESMTP id C2BD968
	for <netdev@vger.kernel.org>; Mon,  6 Apr 2015 17:32:17 +0000 (UTC)
In-Reply-To: <551F2C20.1060908@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2015 05:11 PM, Rick Jones wrote:

>    INSTALL debian/headertmp/usr/include/asm/ (65 files)
> parsechangelog/debian: warning:     debian/changelog(l2): found eof
> where expected first heading
> parsechangelog/debian: error: fatal error occurred while parsing
> debian/changelog
> dpkg-gencontrol: error: changelog parser
> /usr/lib/dpkg/parsechangelog/debian gave error exit status 255
> scripts/package/Makefile:90: recipe for target 'deb-pkg' failed
> make[1]: *** [deb-pkg] Error 255
> Makefile:1238: recipe for target 'deb-pkg' failed
> make: *** [deb-pkg] Error 2
>
> Which I'm afraid goes beyond my knowledge of how to deal.  Does any of
> that - either the VxLAN or the build problem - sound familiar?

Seems the build failure relates to the particulars of the lsb-release 
package on the system on which I was building.

rick
