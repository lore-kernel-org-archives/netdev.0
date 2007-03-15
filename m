From: "Luis Carlos Cobo Rus" <luiscarlos@gmail.com>
Subject: ping DOS avoidance?
Date: Wed, 14 Mar 2007 18:59:56 -0700
Message-ID: <d9dc600703141859x3eeddd4cs51b3aea89d4dc32a@mail.gmail.com>
References: <d9dc600703091718m508cdafbm46a4aad9b613d9c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Netdev List" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:8706 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbXCOB74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 21:59:56 -0400
Received: by an-out-0708.google.com with SMTP id b33so407944ana
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2007 18:59:56 -0700 (PDT)
In-Reply-To: <d9dc600703091718m508cdafbm46a4aad9b613d9c1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm stress testing some network devices by doing some cross flood
pings among them. It occurs  sometimes that one of the hosts (host
foo) will stop answering to pings from other hosts. foo can ping all
the other hosts, and I can use ssh back and forth, but it doesn't
answer ping requests.

More info:
- tcpdump at foo actually shows the ping requests (but no replies)
- other network interfaces connected at foo also stop answering pings
- icmp_echo_ignore_all is 0
- foo cannot even ping itself. I would swear it was able to ping
itself, but just went to confirm it for this mail and found out it
isn't.

I took a look at icmp.c to see where the packet could get dropped but
found nothing. I assume it's some kind of DOS prevention, but I don't
know where it is taking place nor how to revert it. Any hint would be
appreciated.

Thanks in advance!

--
Luis Carlos Cobo Rus       GnuPG ID: 44019B60
cozybit Inc.
