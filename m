From: Ben Greear <greearb@candelatech.com>
Subject: Setting skb timestamp in non GPL module is no longer possible in
 2.6.22-pre7.
Date: Fri, 06 Jul 2007 13:25:51 -0700
Message-ID: <468EA54F.80604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:53766 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755175AbXGFUZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 16:25:52 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l66KPp2d028634
	for <netdev@vger.kernel.org>; Fri, 6 Jul 2007 13:25:51 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I thought I would mention this on the small chance it was an accidental change.

The new __net_timestamp(skb) method uses ktime_get_real which
is exported GPL only.

Now, such evil modules must call net_enable_timestamp(), causing
all packets to be timestamped, not just the ones the evil
module is interested in...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

