From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: 'tcp: bind() fix when many ports are bound' problem
Date: Tue, 4 Jan 2011 10:53:30 +0200
Message-ID: <AANLkTimrpZOWEc5qXPEbrJbt2Nmh2vY69aC1Dwf1cCPH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, gasparch@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:44346 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab1ADIxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 03:53:32 -0500
Received: by pwj3 with SMTP id 3so1838100pwj.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 00:53:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After a series of discussions [1], Eric provided
"tcp: bind() fix when many ports are bound" patch. ([2])

Anyhow, due to this problem ([3]) it was reverted.
Where there any follow ups on this patch?

I have spent some time looking at inet_csk_get_port with the
only conclusion that it's scary :D.

Should I work around patch "tcp: bind() fix when many ports are bound",
and try to fix problem [3], or is that a dead end?

thanks,
Daniel.

[1] http://kerneltrap.org/mailarchive/linux-netdev/2010/4/20/6275120
[2] http://kerneltrap.org/mailarchive/git-commits-head/2010/4/24/32191
[3] http://kerneltrap.org/mailarchive/linux-kernel/2010/4/28/4563937
