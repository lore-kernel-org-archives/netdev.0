From: "Gabor Fekete" <kotrelmaller.borgenbach@gmail.com>
Subject: raw socket and iptables rules
Date: Thu, 10 Apr 2008 14:51:25 +0300
Message-ID: <690153640804100451y7a7f29fawfd6b3f1ba8f62a51@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:6514 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755198AbYDJLvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 07:51:25 -0400
Received: by wf-out-1314.google.com with SMTP id 28so3011098wff.4
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 04:51:25 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm writing a C code that sends IP datagrams using a RAW socket.
The only problem I have is that it seems that the MASQUERADE rule
I have does not apply for the packets sent via this socket.

Is it so, that raw sockets bypass iptables?
What can I do to make iptables to process these packets?

Thanks,
Gabor
