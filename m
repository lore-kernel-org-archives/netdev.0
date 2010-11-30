From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 0/11 net-next] TIPC cleanups for native API removal
Date: Tue, 30 Nov 2010 17:00:52 -0500
Message-ID: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58693 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117Ab0K3WBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The purge of the unused code that existed just to support the draft
API spec (commit 31e3c3f6f1f9b154981a0e6620df700463db30ee) actually
opens the door for several more cleanups of similar nature.  It is
possible to relocate and internalize header file content, reduce the
number of exported symbols further, and manually inline some of the
"used once" functions that used to be separate just to be exported.

Some other largely trivial one-off type cleanups are also included.
Overall, this set of commits should largely be a no-op in terms of
behaviour change though.

Thanks,
Paul.

