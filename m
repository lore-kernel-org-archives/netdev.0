From: varun <varun@rocsys.com>
Subject: help needed in n/w
Date: Thu, 13 Apr 2006 08:49:31 +0530
Message-ID: <443DC343.30806@rocsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [202.125.80.81] ([202.125.80.81]:35024 "EHLO rocsys.com")
	by vger.kernel.org with ESMTP id S932434AbWDMDMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 23:12:33 -0400
Received: from rocsys.com (localhost [127.0.0.1] (may be forged))
	by rocsys.com (8.12.10/8.12.10) with ESMTP id k3C9UFTE019501
	for <netdev@vger.kernel.org>; Thu, 13 Apr 2006 09:36:59 +0530
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

            Iam new to netfilters and iam trying to play around to 
understand a few things. By default when no policies are specified then 
it allows all traffic to go out and in to the n/w. I want to change this 
to default as deny.
            That is when there is no policy all should be default deny.

          So in order to achieve that i tried to change the  code a little.
           In the file iptable_filter.c there is a variable called 
static int forward = NF_ACCEPT
            I changed this to NF_DROP and when i compiled and used it 
sure i was not able to send any or recv any packets
            but even after i give a policy like iptables -t filter -A 
INPUT -j ACCEPT
            Nothing changes. So achieve what i want what should i do? 
And where do i change?

            Another thing is that in normally when i put a policy like 
iptables -t filter -A OUTPUT -j REJECT
             Even my own self IP doesnt ping? Why should this happen?
              Isint it ok to ping local ip and loopback ip?
               If i want such implementation where i should be able to 
ping to self and local but not any other ip?
               Is it possible?
               I dont want to add policies rather is it possible just by 
changing the iptables kernel code?

               Please help me on this?

Varun
