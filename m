From: i trilok <itrilok@gmail.com>
Subject: regarding netlink usage
Date: Fri, 30 Nov 2012 07:06:29 +0530
Message-ID: <CAMr2Gz737cL8hwJ1mTcMYGG2CXZ=dussDc_cJnd+GL0iQ6c4Zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:33642 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530Ab2K3Bg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 20:36:29 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so11430244iay.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 17:36:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was trying to port some module code from 2.6.29 to 2.6.34.10 kernel.
I'm using netlink for communication between kernel module and user
application. In the netlink receive call back function I'm retrieving
netlink message header from (struct nlmsghdr*)skb->data and the same
was working in 2.6.29 kernel but when I ported this to 2.6.34.10 I was
seeing (struct nlmsghdr*)skb->head is holding the netlink message
header instead of skb->data, what could be wrong, is this intended
behavior?.

Thanks in advance.


Thanks,
Ina.
