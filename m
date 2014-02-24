From: Andrey Mazo <mazo@telum.ru>
Subject: [PATCH 0/4] bridge-utils: build system fixes and cleanups
Date: Mon, 24 Feb 2014 14:56:42 +0400
Message-ID: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Cc: Andrey Mazo <mazo@telum.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.telum.ru ([62.141.76.179]:50887 "EHLO mail.telum.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbaBXLCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 06:02:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This short patch series implements several enhancements to the bridge-utils
build system.
The first two patches had already been sent to the bridge list [1,2]
but unfortunately got no response.
I've recently sent the whole patch series to the bridge list [3]
but forgot to CC netdev list.
I appologize if you receive multiple copies of this series.

[1] http://lists.linuxfoundation.org/pipermail/bridge/2013-August/008535.html
[2] http://lists.linuxfoundation.org/pipermail/bridge/2013-August/008536.html
[3] http://lists.linuxfoundation.org/pipermail/bridge/2014-February/008711.html

Andrey Mazo (4):
  bridge-utils: Abort compilation on error in any subdirectory
  bridge-utils: Removed unused variable in doc/Makefile.in
  bridge-utils: AC_OUTPUT should be used without arguments
  bridge-utils: Pretty print configure help

 Makefile.in     |  4 ++--
 configure.ac    | 12 ++++++++----
 doc/Makefile.in |  2 --
 3 files changed, 10 insertions(+), 8 deletions(-)

-- 
1.8.4.5
