From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 0/2] Clean up owner field in sock_lock_t
Date: Tue, 11 Sep 2007 14:01:31 -0400
Message-ID: <11895336933187-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:52003 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758422AbXIKSPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 14:15:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't know why the owner field is a (struct sock_iocb *).  I'm assuming
it's historical.  Can someone check this out?  Did I miss some alternate
usage?

These patches are against net-2.6.24.
