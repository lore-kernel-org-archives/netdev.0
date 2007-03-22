From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/8] [RESEND] netlink error magngement + others
Date: Thu, 22 Mar 2007 23:18:04 +0100
Message-ID: <20070322221804.000124130@lsx.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56174 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161142AbXCVWVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 18:21:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,
I've rediffed all patches and combined the two patchsets into
one.  Patrick has already queued the NLM_F_REQUEST change for
nfnetlink.

[PATCH 0/5] [PATCHSET] Netlink Patches
Converts westwood and vegas netlink code to use the typesafe
interface, removes an unused varaible, and move some netlink
queue management code into the generic layer.

[PATCH 0/3] [PATCHSET] netlink error management
This series of patches simplifies the error management and
signalization of dump starts of netlink_run_queue() message
handlers. It touches a fair bit of nfnetlink code as the
error pointer has been passed on to subsystems.

