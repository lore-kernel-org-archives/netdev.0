From: Olaf van der Spek <ml@vdspek.org>
Subject: Seamless Service Restart / Port Takeover
Date: Wed, 12 Oct 2011 18:53:51 +0200
Message-ID: <CAGVGHmuVnsw4mdsxO=93yaYRgGaj20gR0+nNB_iaS=nTM_BThw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:61842 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680Ab1JLQxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 12:53:52 -0400
Received: by vcbgb30 with SMTP id gb30so745245vcb.19
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2011 09:53:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When restarting a service, a webserver for example, you'd like this to
be seamless for clients. Often, first a signal is send to the old
process to close listening sockets, then the new process is started.
This has both a race condition (sometimes 'avoided' with a sleep in
between) and service interruption.
Wouldn't it be possible to introduce mv / move like behaviour, where
the socket can be rebound without races and without interruption?

Olaf
