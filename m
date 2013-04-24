From: Wei Liu <wei.liu2@citrix.com>
Subject: Some questions regarding dev branches and workflow
Date: Wed, 24 Apr 2013 11:58:27 +0100
Message-ID: <20130424105827.GF7466@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58469 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932107Ab3DXK63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 06:58:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

I have some questions regarding your two branches and workflow.

What release is the current 'net-next' targeting? 3.10 or 3.11?

If I understand correctly, the patches in 'net-next' will eventually go
into 'net', right?

>From your last email, you said the only way for patches to make way to
-stable is to post them against 'net' branch. I can post patches for
fixing Xen XSA-39 regression again 'net'. However as some changes for
netback went in, you might have trouble flipping 'net-next' to 'net'
because of conflicts. So if 'net-next' will become 'net' within a
reasonable amount of time, we can wait until it happens.

I certainly don't want to generate any extra workload for you, that's
why I ask these questions.


Thanks
Wei.
