From: Dyweni - NetDev <xmCM8KtKk25K@dyweni.com>
Subject: Invalid Argument when adding a bond to a bridge
Date: Thu, 22 Dec 2011 08:25:54 -0600
Message-ID: <b8003b95089e177b00bc7db44700757a@pl1.haspere.com>
Reply-To: <xmCM8KtKk25K@dyweni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>,
	Bridge <bridge@lists.linux-foundation.org>,
	Bonding Devel <bonding-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pl1.haspere.com ([208.111.35.220]:42582 "EHLO pl1.haspere.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273Ab1LVOZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 09:25:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi All,

 I need some help figuring this one out... Whenever I try to add a bond 
 to a
 bridge, I get back an invalid argument error. I've confirmed this on
 3.2-rc6, 3.1.5, 3.0.13, and 2.6.39.4 (haven't checked earlier kernels).

 Here's my setup: 32bit KVM virtual machine with no network cards (... 
 -net
 none ... ).

 I created the bond with: echo "+x" > /sys/class/net/bonding_masters

 I created the bridge with: brctl addbr b

 I try to add the bond to the bridge with: brctl addif b x

-- 
 Thanks,
 Dyweni
