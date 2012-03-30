From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: TCP_MAXSEG option with TSO enabled
Date: Fri, 30 Mar 2012 14:33:37 +0300
Message-ID: <CAEnQRZC1sLW8BUOx2ov-S-UUSyfAi7Wem2mAzUHBHn2o9q-eRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:57358 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933785Ab2C3Ldh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 07:33:37 -0400
Received: by ghrr11 with SMTP id r11so209616ghr.19
        for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 04:33:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am using TCP_MAXSEG option on an interface which has TSO enabled.

strace output for connection looks as follows:

socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 26
setsockopt(26, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
setsockopt(26, SOL_TCP, TCP_NODELAY, [1], 4) = 0
setsockopt(26, SOL_TCP, TCP_MAXSEG, [300], 4) = 0
connect(26, {sa_family=AF_INET, sin_port=htons(1935),
sin_addr=inet_addr("10.10.0.1")}, 16) = -1 EINPROGRESS (Operation now
in progress)

I can see that MSS (300) is advertised in SYN packet, anyhow capturing
the traffic
I notice that are some TCP segments with length greater than MSS.

Is this normal taking in consideration that TSO is enabled?

thanks,
Daniel.
