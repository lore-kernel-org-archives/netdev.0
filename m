From: MohammadReza Jamali <mrezajamali@gmail.com>
Subject: Access Network Device Driver from the Kernel
Date: Thu, 7 Feb 2013 17:19:26 +0330
Message-ID: <CAHyZ6WrWZvae_y-v8j0wGV2Prin6FTL6xtLHTjWn3D=NtDU1yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:60979 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010Ab3BGNzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 08:55:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all
I want to implement Openss7 over Sangoma A104 card. Openss7 is a
Stream (includes some modules in the kernel)and I want to communicate
with the card driver (Wanpipe) from this Stream (from the lowest
module). Does anybody have a general idea for this? I have worked on
this for more than one month and I have reached to this approach:
At one hand I should build a Stream (kernel modules) based on Openss7
and at the other hand I should read and write Wanpipe from the lowest
kernel module of the Stream. As far as I know Wanpipe is a network
device driver (Correct me if I am wrong!) and I should read this
device with socket programming from the user space but how from the
kernel space? If I am completely wrong: I would be very thankful if
somebody suggests another approach.
thanks in advance
