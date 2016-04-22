From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] devlink: export header
Date: Fri, 22 Apr 2016 09:55:17 -0700
Message-ID: <20160422095517.545fe658@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35592 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513AbcDVQzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 12:55:06 -0400
Received: by mail-pf0-f179.google.com with SMTP id n1so43069743pfn.2
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 09:55:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export devlink.h when doing make headers install.
I am going to investigate just doing all headers in the directory,
but lets add missing piece for now.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/include/uapi/linux/Kbuild	2016-03-29 17:25:37.727993065 -0700
+++ b/include/uapi/linux/Kbuild	2016-04-22 09:49:10.317523852 -0700
@@ -96,6 +96,7 @@ header-y += cyclades.h
 header-y += cycx_cfm.h
 header-y += dcbnl.h
 header-y += dccp.h
+header-y += devlink.h
 header-y += dlmconstants.h
 header-y += dlm_device.h
 header-y += dlm.h
