From: "kalyan tejaswi" <kalyanatejaswi@gmail.com>
Subject: degradation in network performance upto 20 % in 2.6.18 when compared to 2.6.17
Date: Fri, 29 Dec 2006 18:28:51 +0530
Message-ID: <9dd3c65d0612290458l2b110341ob31c7212f51efbc8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:35935 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbWL2M6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 07:58:52 -0500
Received: by py-out-1112.google.com with SMTP id a29so2646543pyi
        for <netdev@vger.kernel.org>; Fri, 29 Dec 2006 04:58:51 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hi all,
I have been comparing routing and bridging performance tests for
2.6.16,2.6.17,2.6.18,2.6.19 kernels.
The setup is:


       ------------------------
eth0     ------------------------
       |                              |
<---------------------------------->|                                |
       |  Smartbits            |
            |    Malta 4Kc            |
       |                              |
<---------------------------------->|                                |
       ------------------------
eth1     -------------------------


I use D-Link cards for the Malta 4Kc board.
I see that 2.6.18 and 2.6.19 have almost identical performance
figures. Also, same is observed with 2.6.16 and 2.6.17.

But 2.6.16/2.6.17   is roughly 20% better than 2.6.18/2.6.19

Are these results justified? Has anyone observed similar behaviour?
What could be the reason?


Regards
Kalyan
