From: Lawrence Lee <lawrenceqli@gmail.com>
Subject: Using dev_queue_xmit causes a system halt problem.
Date: Mon, 3 Jun 2013 22:05:04 +0200
Message-ID: <CAGXkBO8tYr9c2=m6O=ZmB7u9=xvn9bCrjqsFozTTzSnz4n-n3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:53232 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758444Ab3FCUFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 16:05:05 -0400
Received: by mail-ie0-f179.google.com with SMTP id c13so156992ieb.38
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 13:05:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I use netfilter to hook packets at the NF_INET_LOCAL_OUT hook and send
the packets using dev_queue_xmit(). My module can successfully sends
packets. Unfortunately, the system always halts when my module is
installed. It seems that using dev_queue_xmit() causes an issue of a
deadlock. The problem is same when I use ndo_start_xmit() to send
packets. However, I am not sure what the exact problem is. May I know
how I can fix this problem. Thank you!

Best,
Lawrence
