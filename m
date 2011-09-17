From: "J.Hwan.Kim" <j.hwan.kim99@gmail.com>
Subject: unicast hash in ixgbe and ixgbevf
Date: Sat, 17 Sep 2011 20:02:51 +0900
Message-ID: <4E747E5B.4050207@gmail.com>
Reply-To: frog1120@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:33827 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab1IQLDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 07:03:02 -0400
Received: by iaqq3 with SMTP id q3so3178449iaq.19
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2011 04:03:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, everyone

I'm using intel ixgbe and ixgbevf driver and SR-IOV option.

Is there any method for distributing the random IP packet stream
into several VF queues evenly?

For example, for each 4 VF queues,
can each a quarter of the IP stream be distributed to each 4 VF queues?

I checked the PFUTA register and tested it, but as far as I know,
with the 4K bit hash table, the stream is directed to queues
of which ROPE bit is set.
So, the stream is duplicated to the queues of which ROPE bit is set.
That is not what I want to do.

How can I distribute the random IP packets to several VF queues
without duplicating?

Thanks in advance.

Best Regards,

J.Hwan Kim
