From: jwestfall <jwestfall@surrealistic.net>
Subject: bridge not forwarding stp bpdu's
Date: Mon, 29 Dec 2008 21:23:33 -0800
Message-ID: <20081230052333.GF4969@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from whipper.surrealistic.net ([67.40.222.188]:39873 "EHLO
	whipper.surrealistic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbYL3Fgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 00:36:32 -0500
Received: from jwestfall by whipper.surrealistic.net with local (Exim 4.69)
	(envelope-from <jwestfall@surrealistic.net>)
	id 1LHX4n-00073J-AQ
	for netdev@vger.kernel.org; Mon, 29 Dec 2008 21:23:33 -0800
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

In testing 2.6.27.10 in the lab I have come across an issue/behavior 
change in the bridge code.  Its no longer forwarding stp bpdu's when 
the bridge has stp disabled.

I traced the issue down to commit 43aa1920117801fe9ae3d1fad886b62511e09bee, 
http://marc.info/?l=linux-netdev&m=121372162127805&w=2

This directly reverts commit c2886d6259b8faac4c05ffd9c3c401ac84478de0, 
http://marc.info/?l=linux-netdev&m=117745652925118&w=2, which was made 
to allow bpdu's to pass when stp is not enabled.

Is this expected?

thanks
jim
