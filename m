From: "J.Hwan Kim" <frog1120@gmail.com>
Subject: Intel 82599 ixgbe driver performance
Date: Wed, 10 Aug 2011 15:19:34 +0900
Message-ID: <4E4222F6.7050304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f170.google.com ([209.85.210.170]:32802 "EHLO
	mail-iy0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab1HJGTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 02:19:37 -0400
Received: by iye16 with SMTP id 16so563463iye.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 23:19:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, everyone

I'm testing our network card which includes intel 82599 based on ixgbe 
driver.
I wonder what is the Rx performance of i82599 without network stack only 
with 64Byte frames.
Our driver reads the packet directly from DMA packet buffer and push to 
the application
without passing through linux kernel stack.
It seems that the intel 82599 cannot push 64B frames to DMA area in 10G.
Is it right?

If it is the case, what is the bottleneck of 82599?

Thanks in advance.

Best Regards,
J.Hwan KIm





