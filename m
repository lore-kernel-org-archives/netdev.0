From: Ben Greear <greearb@candelatech.com>
Subject: iproute2 issue with adding rules.
Date: Mon, 17 May 2010 12:03:21 -0700
Message-ID: <4BF192F9.8000008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41883 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab0EQTDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 15:03:22 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o4HJ3LBw023643
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 12:03:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On older releases, you can do this with iproute:

# ip ru add from 9.9.9.2/32 table 226 pref 400
#

But, in latest git, it returns an error:
# ip ru add from 9.9.9.2/32 table 226 pref 400
Error: an inet prefix is expected rather than "9.9.9.2/32".

Is that on purpose?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

