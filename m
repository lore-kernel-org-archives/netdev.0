From: Ren Junyuan <renjy@cn.fujitsu.com>
Subject: Question about the email about "[PATCH 2/3] IPV6: unify 3 similar
 code path in ndisc_recv_ns()"
Date: Thu, 08 Nov 2007 15:04:40 +0800
Message-ID: <4732B508.60100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@sunset.davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:63490 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751843AbXKHHG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 02:06:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear David S. Miller :

Happy to write to you.
In the email  <20040206.181006.79694138.yoshfuji@linux-ipv6.org >
<http://oss.sgi.com/archives/netdev/2004-02/msg00111.html>>,
yoshfuji unified 3  similar code patch in ndisc_recv_ns(). I have a 
question
about the "flags sent with  
NA in reply to this NS" .  In the kernel 2.4.21,
it is as follows:
 ndisc_send_na(dev, neigh, saddr,
                  &msg->target,
                      idev->cnf.forwarding, 1, 0, inc);
in you patch it is as follows:
ndisc_send_na(dev, neigh, saddr, &msg->target,
                idev->cnf.forwarding,
                1, (ifp != NULL && inc), inc);
Can you tell me why you modified the flag O(override)?
Thanks a lot!

-- 
Regards
Ren Junyuan
 --------------------------------------------------
 Ren Junyuan
 Development Dept.I
 Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
 8/F., Civil Defense Building, No.189 Guangzhou Road,
 Nanjing, 210029, China 
 TEL: +86+25-86630566-851
 COINS: 79955-851
 FAX: +86+25-83317685
 MAIL: renjy@cn.fujitsu.com


