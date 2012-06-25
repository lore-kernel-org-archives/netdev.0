From: Christian Franke <nobody@nowhere.ws>
Subject: pneigh/NLF_PROXY: should NLM_F_EXCL be honored?
Date: Mon, 25 Jun 2012 15:23:55 +0200
Message-ID: <4FE8666B.9040805@nowhere.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus.nowhere.ws ([78.111.67.33]:38632 "EHLO zeus.nowhere.ws"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756365Ab2FYNbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 09:31:23 -0400
Received: from [172.22.92.125] (buster.dn42.nowhere.ws [172.22.92.125])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by zeus.nowhere.ws (Postfix) with ESMTPSA id C89E67EA45
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 15:23:55 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

by sending RTM_NEWNEIGH with NLF_PROXY in the ndmsg, a new proxy entry
can be added.

The code path taken ignores NLM_F_EXCL, returning success, even if the
proxy entry does already exist. Is this intended behaviour?

Best Regards,
Christian Franke
