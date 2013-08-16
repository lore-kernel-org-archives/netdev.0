From: Ben Greear <greearb@candelatech.com>
Subject: Provide ability to change default netdev name?
Date: Fri, 16 Aug 2013 15:14:23 -0700
Message-ID: <520EA43F.2010304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49928 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021Ab3HPWOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:14:24 -0400
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r7GMENeL021647
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 15:14:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The latest udev in Fedora 19 (and perhaps elsewhere) will no longer
implement rules that rename an interface from ethX to ethY.  Nor
wlanX or other 'kernel namespaces'.  The Fedora udev developers do not seem
interested in changing this back to the old behaviour, evidently they
had a hard time implementing it properly.

This effectively makes it impossible to have network device names of ethX
consistent across reboots in systems with multiple NICs and/or drivers.

One way to work around this would be allow the kernel to use a different
default netdev name (for instance, keth%d).  I'm thinking this would be
configured as a kernel command line argument.  Then, a small change to udev/systemd to
make the 'kernel namespaces' configurable by letting it understand this new kernel
command line argument should resolve the problem.

Does this sound like something that could be accepted upstream?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
