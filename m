From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: NVGRE for Linux
Date: Mon, 10 Jun 2013 18:21:46 +0300
Message-ID: <CAEnQRZBFHd4_cF2VMtd=QAheXbrz7qof0qC-3DjUSZ-04bR+Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:60033 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867Ab3FJPVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 11:21:47 -0400
Received: by mail-wi0-f178.google.com with SMTP id k10so3239791wiv.5
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 08:21:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is there anyone working on implementing NVGRE [1] in Linux kernel?

A significant part of the code can be borrowed from VXLAN [2] (netlink
ops, fdb ops),
while another important part (packet reception/transmission) is based
on GRE tunneling code [3].

Is this approach correct? Any suggestions are welcomed.

thanks,
Daniel.

[1] http://datatracker.ietf.org/doc/draft-sridharan-virtualization-nvgre/
[2] drivers/net/vxlan.c
[3] net/ipv4/ip_gre.c
