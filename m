From: Syed Obaid Amin <obaidasyed@gmail.com>
Subject: About disabling congestion control
Date: Thu, 6 Jan 2011 20:25:18 -0500
Message-ID: <AANLkTin53drsv18TZ0CPZM7==6G=rK6vScUb=SCQ4-xr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55149 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975Ab1AGBZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 20:25:20 -0500
Received: by fxm20 with SMTP id 20so16563645fxm.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 17:25:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all,

I am currently working on a socket option to disable the tcp
congestion control. I think the simplest approach to do this is to
ignore cwnd before sending out a packet.

After going through tcp output engine it seems that tcp_cwnd_test is
the method that decides that how many segments can be sent out on a
wire. For testing it out, I changed this method so that if no-cc
option is ON, just return a big constant value. But, it didn't work
and I am unable to see a burst of pkts. It looks like that I am
missing something here.

Any suggestions that what is the right place to look for disabling the
congestion control ?

Thanks much!

Obaid
