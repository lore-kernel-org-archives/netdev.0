From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-2.6 [PATCH 0/2] udp/dccp: MSG_TRUNC
Date: Thu, 11 Feb 2010 07:26:17 +0100
Message-ID: <1265869579-5829-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <udp_dccp_msg_trunc>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51478 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750897Ab0BKG0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2010 01:26:37 -0500
In-Reply-To: <udp_dccp_msg_trunc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I have here two datagram-API patches, both submitted for net-2.6:

Patch #1: Resolves missing MSG_TRUNC support. Since DCCP is datagram-based,
          the user-space API is broken/incomplete without.

Patch #2: UDP recvmsg() cleanup, remove redundant variable. 	  
