From: "J.Hwan Kim" <frog1120@gmail.com>
Subject: intel 82599 multi-port performance
Date: Mon, 26 Sep 2011 19:26:33 +0900
Message-ID: <4E805359.2080600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37241 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267Ab1IZK0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 06:26:36 -0400
Received: by iaqq3 with SMTP id q3so4394416iaq.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 03:26:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, everyone

Now, I'm testing a network card including intel 82599.
In our experiment, with the driver modified with ixgbe and multi-port 
enabled,
rx performance of each port with 10Gbps of 64bytes frame is
a half than when only 1 port is used.
The pcie of our server is GEN2 (5x X 8).

Is the result reasonable?
When multi-ports are enabled and 10G stream is inserted to each port,
the maximum performance of each port is a half in our experiment.

Do you think it is a problem of our modified driver or the performance
bottleneck of 82599?
Now I cannot understand our experiment result.
Please give me an advice.

Thanks in advance.

Best Regards,
J.Hwan Kim
