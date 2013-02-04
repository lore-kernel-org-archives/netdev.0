From: Stephen Hemminger <stephen@networkplumber.org>
Subject: iproute2 patches
Date: Mon, 4 Feb 2013 08:53:34 -0800
Message-ID: <20130204085334.76c1451d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: c.van.reeuwijk@vu.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:44408 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907Ab3BDQxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 11:53:50 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so882731pad.9
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 08:53:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the delay, your patches are good, but the formatting is incorrect
and they do not apply. See kernel documentation on SubmittingPatches.
They need to be based correctly so that a maintainer can just use either
'patch' or 'git am' to apply them. Your patches do not have the correct
path.

For example the patch:

diff --git a/libnetlink.3 b/libnetlink.3
index 15a478a..4c70678 100644
--- a/libnetlink.3
+++ b/libnetlink.3

Should be based at root:
diff --git a/man/man3/libnetlink.3 b/man/man3/libnetlink.3
index 15a478a..d114169 100644
--- a/man/man3/libnetlink.3
+++ b/man/man3/libnetlink.3
