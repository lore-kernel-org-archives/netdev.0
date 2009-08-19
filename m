From: Sumedha Gupta <2sumedha@gmail.com>
Subject: (unknown)
Date: Wed, 19 Aug 2009 10:59:56 -0400
Message-ID: <869c36e20908190759p604d9a92pcd96e198a787eeec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f172.google.com ([209.85.212.172]:59528 "EHLO
	mail-vw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbZHSO74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 10:59:56 -0400
Received: by vws2 with SMTP id 2so3772651vws.4
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 07:59:57 -0700 (PDT)
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have set up NIC bonding on a computer. NIC has four ports each with
a capacity of 1 Gbps. After configuring the switch, I am able to get
approximately 3.5 Gbps with round-robin, TLB and ALB and 3Gbps with
XOR. However when I remove bonding and give each port (eth0, eth1,
eth2, eth3) a different IP address and mac address and send data from
4 different client machines to different ports e.g first machine --->
eth0, second machine --->eth1, third machine ---->eth2 and fourth
machine---->eth3. With this configuration, how much bandwith should I
get? I think I should get 4 Gbps because I am using 4 different IP
address they should respond individually. However I am getting 1Gbps
total. Please correct if I am wrong and if I should get 4 Gbps then I
do I need to change something in configuration?
