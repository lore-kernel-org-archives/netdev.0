From: Javier Domingo <javierdo1@gmail.com>
Subject: Softirqs without captured packets
Date: Fri, 8 Feb 2013 20:41:08 +0100
Message-ID: <CALZVap=wdDnTndwa+Q+MLCufj9YpY-m+wATFiKSTX2bXX-9DVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f43.google.com ([209.85.212.43]:64071 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946899Ab3BHTla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 14:41:30 -0500
Received: by mail-vb0-f43.google.com with SMTP id fs19so2547191vbb.16
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 11:41:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have created a tracer module that makes a measure of time at the
start and at the end of a softirq, and also the captured packets in
it.

I have made the measurements using sched_clock() for the time and
summing up the work variable after each poll (in the net_rx_action
polling loop).

I have noticed quite strange results. There are many softirqs that end
up with 0 captured packets.

This is the trace I created and has the following format <start time>
- <end time> : <captured packets>.

As you will notice, thought many of them have some packet captured,
there are many others that don't.

Any help/explanation is welcome!,

Javier Domingo
