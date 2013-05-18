From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Please revert port per vxlan in 3.10
Date: Fri, 17 May 2013 20:57:57 -0700
Message-ID: <20130517205757.2048df89@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:52086 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306Ab3ERD6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 23:58:02 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so1378084pde.37
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 20:58:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you won't take the multiple listen port value patch.
Then please use -net to revert this commit so it doesn't show up in a
broken state in 3.10. But keep it in for net-next.

commit 823aa873bc782f1c51b1ce8ec6da7cfcaf93836e
Author: stephen hemminger <stephen@networkplumber.org>
Date:   Sat Apr 27 11:31:57 2013 +0000

    vxlan: allow choosing destination port per vxlan
    
    Allow configuring the default destination port on a per-device basis.
    Adds new netlink paramater IFLA_VXLAN_PORT to allow setting destination
    port when creating new vxlan.
    
    Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>
