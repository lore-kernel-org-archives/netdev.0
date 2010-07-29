From: Steve Chen <schen@mvista.com>
Subject: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Wed, 28 Jul 2010 22:20:05 -0500
Message-ID: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:45351 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886Ab0G2DUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 23:20:07 -0400
Received: by iwn7 with SMTP id 7so113408iwn.19
        for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 20:20:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The TAHI correspondent node tests CN-6-4-1 (Processing in upper layer
- Echo Checksum) failed for me in the 2.6.32 kernel.  It appears that
the Linux kernel is replying the ICMP echo request in
icmpv6_echo_reply without much checking.  Is this an intentional
non-conformance to RFC3775 section 9.3.1?

Thanks,

Steve
