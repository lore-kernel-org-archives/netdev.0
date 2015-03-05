From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] net: dsa: code re-organization
Date: Thu,  5 Mar 2015 12:35:03 -0800
Message-ID: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:40210 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbbCEUgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 15:36:12 -0500
Received: by padfb1 with SMTP id fb1so36214315pad.7
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 12:36:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This pull request contains the first part of the patches required to implement
the grand plan detailed here:

http://www.spinics.net/lists/netdev/msg295942.html

These are mostly code re-organization and function bodies re-arrangement to
allow different callers of lower-level initialization functions for 'struct
dsa_switch' and 'struct dsa_switch_tree' to be later introduced.

There is no functional code change at this point.

Thanks!

Florian Fainelli (5):
  net: dsa: update dsa_of_{probe,remove} to use a device pointer
  net: dsa: allow deferred probing
  net: dsa: split dsa_switch_setup into two functions
  net: dsa: let switches specify their tagging protocol
  net: dsa: extract dsa switch tree setup and removal

 include/net/dsa.h |   5 ++
 net/dsa/dsa.c     | 214 ++++++++++++++++++++++++++++++------------------------
 2 files changed, 126 insertions(+), 93 deletions(-)

-- 
2.1.0
