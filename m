From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: [PATCH 0/5] [DCCP]: Queuing policies
Date: Fri, 11 Apr 2008 11:24:06 +0100
Message-ID: <200804111224.06958.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:2191 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757717AbYDKKiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 06:38:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is resubmission of queuing policy related patches for DCCP. Queuing 
policies allow userspace applications to more effectively use DCCP. Changes 
include:
 - CodingStyle,
 - do not allow applications to change qpolicy after accept or connect,
 - naming changes,
 - make dccps_qpolicy a non-pointer,
 - include dccpd_policy in dccp_skb_cb as a structure not char[16].
-- 
Regards,
Tomasz Grobelny
