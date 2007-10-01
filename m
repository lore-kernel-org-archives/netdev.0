From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.24 0/4]: TCP fixes
Date: Mon,  1 Oct 2007 15:29:40 +0300
Message-ID: <11912417841620-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49158 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbXJAM3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 08:29:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This fixes the newreno fackets_out case, which turned out to be
not related to the Cedric's case being under investigation. Two
trivial comment patches, and frto with high-speed seqno
wrap-around protection. Compile tested. Please apply to
net-2.6.24.

-- 
 i.


