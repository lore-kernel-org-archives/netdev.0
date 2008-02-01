From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH 0/2] rtnetlink locking and notification fixes
Date: Fri,  1 Feb 2008 17:06:59 +0100
Message-ID: <12018820194128-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:53322 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005AbYBAQHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:07:01 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 3DBDBC1637
	for <netdev@vger.kernel.org>; Fri,  1 Feb 2008 17:06:59 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These two patches remove unnecessary locks from rtnetlink, it was managed in
an inconsistent way, and change notification. The latter is always sent
if anything is changed but for compatibility the old nofification is also kept.

Regards,
    Attila
