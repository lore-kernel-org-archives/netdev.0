From: Andy Johnson <johnsonzjo@gmail.com>
Subject: Rtnelink and notifcations: a question.
Date: Wed, 22 May 2013 09:13:36 +0300
Message-ID: <CAF0Lin08QxdKRTXUJOuHeRBwfueUks0Scrx+c5FjZmA_4+FNSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:38713 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754282Ab3EVGNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 02:13:37 -0400
Received: by mail-wg0-f46.google.com with SMTP id l18so806351wgh.25
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 23:13:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is a theoretical question (sorry,-)). I was wondering why do we
need both rtnetlink
kernel sockets and the notification API ?
For example,
in net/core/dev.c,
we use notification to send NETDEV_REGISTER event notification in:
call_netdevice_notifiers(NETDEV_REGISTER, dev);
and we use the rtnetlink to send RTM_NEWLINK message:
rtmsg_ifinfo(RTM_NEWLINK,...);


Is it possible to use only the rtnetlink API and to send events like
NETDEV_REGISTER with rtnetlink methods ?

Or is there something inherent with rtnetlink/notification that
prevents implementing in
this way ?

I believe that the other way (solely using notification API) is not
possible because
we need to support getting messages
from userspace (for example, with the iproute package).



Regards,
Andy
