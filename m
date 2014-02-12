From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] intel: Remove unnecessary OOM messages
Date: Tue, 11 Feb 2014 17:26:37 -0800
Message-ID: <1392168397.23721.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0132.hostedemail.com ([216.40.44.132]:52311 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751533AbaBLB0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:26:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't emit these as there's a generic OOM with a dump_stack()
on allocation failures.

Signed-off-by: Joe Perches <joe@perches.com>
---
