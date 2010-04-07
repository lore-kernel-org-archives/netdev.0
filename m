From: Yongjian Zhang <brianzhang2007@gmail.com>
Subject: newbie question about qdisc_watchdog_schedule
Date: Tue, 6 Apr 2010 20:52:13 -0600
Message-ID: <p2u7d5af59c1004061952o9037e7efqce4eb29362819494@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f193.google.com ([209.85.222.193]:49682 "EHLO
	mail-pz0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754322Ab0DGCwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 22:52:34 -0400
Received: by pzk31 with SMTP id 31so610718pzk.33
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 19:52:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have a newbie question about qdisc_watchdog_schedule(). This
function appears in the source code of several qdiscs and it seems to
be used when the qdisc is asked to dequeue a packet but cannot.

I tried to trace the source code but only found some function calls to
start a timer. No callback function seems to be involved...

Google did not give me any documentation to this function either...

Can anyone maybe show me what does qdisc_watchdog_schedule() do and/or
why we have to call it when there's no packet to dequeue?

Thanks a lot!

Jack
