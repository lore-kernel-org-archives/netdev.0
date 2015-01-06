From: Ani Sinha <ani@arista.com>
Subject: Fwd: [PATCH 1/1] update ip-sysctl.txt documentation
Date: Tue, 6 Jan 2015 14:02:29 -0800
Message-ID: <CAOxq_8OGx9VgSaEimAbNZSWjihNqNBXoVg0m8EPRaNX5jLXZiw@mail.gmail.com>
References: <1420574648-24213-1-git-send-email-ani@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:43422 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbbAFWCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 17:02:50 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so429954iec.8
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 14:02:50 -0800 (PST)
In-Reply-To: <1420574648-24213-1-git-send-email-ani@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+netdev


---------- Forwarded message ----------
From: Ani Sinha <ani@arista.com>
Date: Tue, Jan 6, 2015 at 12:04 PM
Subject: [PATCH 1/1] update ip-sysctl.txt documentation
To: corbet@lwn.net, davem@davemloft.net, edumazet@google.com,
linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
ani@arista.com, P@draigbrady.com


Update documentation to reflect the fact that
/proc/sys/net/ipv4/route/max_size is no longer used for
ipv4.

Signed-off-by: Ani Sinha <ani@arista.com>
---
 Documentation/networking/ip-sysctl.txt |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt
b/Documentation/networking/ip-sysctl.txt
index 9bffdfc..c8a7e37 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -64,8 +64,10 @@ fwmark_reflect - BOOLEAN
        Default: 0

 route/max_size - INTEGER
-       Maximum number of routes allowed in the kernel.  Increase
-       this when using large numbers of interfaces and/or routes.
+        Post linux kernel 3.6, this is depricated for ipv4 as route cache is no
+        longer used. For ipv6, this is used to limit the maximum number of ipv6
+        routes allowed in the kernel.  Increase this when using large
numbers of
+        interfaces and/or routes.

 neigh/default/gc_thresh1 - INTEGER
        Minimum number of entries to keep.  Garbage collector will not
--
1.7.4.4
