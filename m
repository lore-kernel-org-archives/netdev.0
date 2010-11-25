From: Jonas Bonn <jonas@southpole.se>
Subject: ethoc driver changes (version 2)
Date: Thu, 25 Nov 2010 13:30:24 +0100
Message-ID: <1290688232-25142-1-git-send-email-jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38968 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab0KYMaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:30:35 -0500
Received: from needafix.southpole.se (needafix.southpole.se [192.168.16.197])
	by mail.southpole.se (Postfix) with ESMTPA id 4F1D2480137
	for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 13:30:31 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series incorporates the changes requested in the review of the original
set.  The patch to "prevent overflow of cur_rx" has been dropped
completely and the comments concerning the usage of division in the
calculation of the BD entry have been incorporated into a new patch, 
number 8 "remove division from loops"; this new patch should take care of
the potential overflow issues that existed previously, too.

/Jonas

