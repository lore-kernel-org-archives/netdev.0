From: Jon Schipp <jonschipp@gmail.com>
Subject: /proc/net/softnet_stat & NAPI
Date: Tue, 20 Nov 2012 13:06:52 -0500
Message-ID: <CAB15j_Dv8hQCDzAYxkTGs5yjz5uhETuhgRxfAvbVbt5mx-P33A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:50336 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab2KTSGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 13:06:52 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so6185031oag.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 10:06:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In relation to packet drops, assuming a new kernel, NAPI driver, and
no use of receive packet steering,
does /proc/net/softnet_stats provide any useful packet drop information?

I know that on earlier 2.4 kernels one could grab the drops in the
backlog queue from 2nd column in /proc/net/softnet_stats.
In a modern systems that use NAPI, does softnet_stats serve a similar
purpose e.g. display drops in a NAPI poll queue?

Thanks
Jon
