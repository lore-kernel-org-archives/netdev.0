From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] qdisc oops fix
Date: Tue, 15 Apr 2003 09:09:05 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030415084706.O1131@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, "" <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Tomas Szepe <szepe@pinerecords.com>
List-Id: netdev.vger.kernel.org


Hi,

Pass those net patches to the maintainers (not Alan, not Linus, not
Marcello) and CC netdev (optionally cc lk)?

I dont understand why

-       sch = kmalloc(size, GFP_KERNEL);
+       sch = kmalloc(size, GFP_ATOMIC);

mysteriously fixes the problem? Could the problem be elsewhere?
Can you repost what the issue was? I am not on lk and i just saw the
posting on a web page.

cheers,
jamal
