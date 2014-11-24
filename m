From: Josh Clark <jcinma@gmail.com>
Subject: qstats update in packet scheduling
Date: Mon, 24 Nov 2014 12:06:15 -0500
Message-ID: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:61890 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaKXRG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 12:06:57 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so13057737wgh.37
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 09:06:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I'm working on a research project to add some extra functionality to
RED. Right now, I'm tracking qstats to look at the factors that RED
uses to calculate marking probability. Using standard RED with printk
debug statements, I'm seeing that there are some drops, but no change
in qlen or backlog when I send 12Mbps through a 10Mbps link.

Does RED use some other means to update qstats and track backlog, or
do I need to change how I'm sending the test traffic though?

Thank you for all your help.




-Josh Clark
