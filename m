From: Ben Greear <greearb@candelatech.com>
Subject: pktgen and tos
Date: Wed, 20 Aug 2014 14:52:00 -0700
Message-ID: <53F51880.5060704@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:51810 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbaHTV5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 17:57:12 -0400
Received: from [50.54.140.2] (50-54-140-2.evrt.wa.frontiernet.net [50.54.140.2])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id B210540CC1A
	for <netdev@vger.kernel.org>; Wed, 20 Aug 2014 14:52:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a half-arsed bug report, in case someone is bored.

At least in my hacked up pktgen, you cannot set a one-digit tos,
because the parser fails if length is not 2 digits.

echo tos 4 > /proc/net/pktgen/rddVR2 && cat /proc/net/pktgen/rddVR2

...
Result: ERROR: tos must be 00-ff

If you use '04' instead, it works.  In my case, it will be easier to hack user-space
to deal with this than fix pktgen, but I thought someone might want to fix it proper.

Also, could be that upstream code doesn't have this limitation...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
