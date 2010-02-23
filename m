From: Christian Kujau <lists@nerdbynature.de>
Subject: Peer unexpectedly shrunk window
Date: Tue, 23 Feb 2010 12:09:35 -0800 (PST)
Message-ID: <alpine.DEB.2.01.1002231154290.28195@bogon.housecafe.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


OK, the "Treason uncloaked" messages have been reworded[0][1] to now say 
"Peer [...] unexpectedly shrunk window", but the messages continue to 
appear. On a small Tor node (~100KB/s, ~200 connections) I'm getting ~2000 
or so messages per month in my kernel log (and on the console).

I see that it's logged with KERN_DEBUG, is there anyway to suppress 
those, i.e. some magic tcp specific bootparameter? Or is setting 
loglevel=6 the only way to supress them? But that's a global option :-\

Since the messages always say "repaired", why log them at all? If we can't 
do something about the remote side, I fail to see the point of these 
messages or what one is supposed to do to "fix" them.

Thanks for your insights,
Christian.

[0] http://lkml.org/lkml/2008/12/18/454
[1] http://kerneltrap.org/mailarchive/linux-netdev/2009/4/19/5518144
-- 
BOFH excuse #399:

We are a 100% Microsoft Shop.
