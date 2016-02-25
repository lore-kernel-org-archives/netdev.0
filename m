From: Dan Streetman <dan.streetman@canonical.com>
Subject: for stable: xfrm: Let the flowcache handle its size by default.
Date: Thu, 25 Feb 2016 14:25:04 -0500
Message-ID: <CAOZ2QJOO714Zpo7mJsXYp6Ln3MAmPi0TbhDXdd8DLL6EA=oNYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:36473 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933357AbcBYTZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 14:25:44 -0500
Received: by mail-yw0-f176.google.com with SMTP id e63so50912447ywc.3
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 11:25:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

can you queue commit c386578f1cdb4dac230395a951f88027f64346e3 for stable?

Without it, any system with > 16 cpus and a lot of ipsec use, that
leaves xfrmN_gc_thresh set to its default, will (eventually) see
failures to create new ipsec connections.

It fixes commit 703fb94ec58e0e8769380c2877a8a34aeb5b6c97.

commit eeb1b73378b560e00ff1da2ef09fed9254f4e128 also tried to fix it,
but didn't increase the value enough and so only fixed the problem for
< 16 cpu systems.

thanks!
