From: Andrew Morton <akpm@linux-foundation.org>
Subject: net nasties in davem's tree
Date: Thu, 29 Mar 2007 18:37:30 -0700
Message-ID: <20070329183730.566f41c6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45401 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752609AbXC3Bhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 21:37:32 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id l2U1bVkB007745
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 18:37:31 -0700
Received: from akpm.corp.google.com (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id l2U1bUTv017442
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 18:37:31 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/3c523.c: In function 'elmc_send_packet':
drivers/net/3c523.c:1148: warning: passing argument 2 of 'skb_copy_from_linear_data' discards qualifiers from pointer target type
drivers/net/ni52.c: In function 'ni52_send_packet':
drivers/net/ni52.c:1185: warning: passing argument 2 of 'skb_copy_from_linear_data' discards qualifiers from pointer target type
