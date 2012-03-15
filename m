From: yao zhao <yao.development@gmail.com>
Subject: setns question
Date: Thu, 15 Mar 2012 09:50:36 -0400
Message-ID: <CADDf=MSHZUeq8V9jx9ybofCu9m=_L2vYaNRhFEd9EL0AVi5O4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41898 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308Ab2CONuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 09:50:37 -0400
Received: by yhmm54 with SMTP id m54so3116642yhm.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 06:50:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Can I ask some questions about setns?

1.setns is complete > 3.0 but right now it doesn't support mnt and pid yet.
2.setns can set a process' uts, net, ipc to different namespace, it is
not fd based, right?
3.is this supported:
     ProcessA's uts == ProcessB's uts
     ProcessA's ipc == ProcessC's ipc
     ProcessA's net == ProcessD's net

thanks,
yao
