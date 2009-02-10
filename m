From: Pavel Roskin <proski@gnu.org>
Subject: Where is Thomas Graf (libnl maintainer)?
Date: Tue, 10 Feb 2009 17:24:26 -0500
Message-ID: <1234304666.14153.8.camel@mj>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:44323 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752782AbZBJWYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 17:24:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I've made 5 patches for libnl, but I don't know where to send them.  My
messages to Thomas Graf bounce, and there is no other contact
information in libnl sources or on the libnl site (the later is down).

The reason I'm asking here is because libnl is hosted on the kernel
site: http://git.kernel.org/?p=libs/netlink/libnl.git

Among the fixes:

$ stg series -d
+ compile-fix-limits # Include limits.h to fix undefined ULONG_MAX in src/utils.c
+ make-parallel      # Fix parallel build
+ make-clean-solibs  # Remove all versioned libraries on "make clean"
+ real-inline        # nl_object_priv() is inline, so define it in the header
> separate-link      # Separate compiling from linking

Maybe someone else could apply my patches if I post them here?

-- 
Regards,
Pavel Roskin
