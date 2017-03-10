From: fgao@ikuai8.com
Subject: [PATCH v3 net-next 0/2] net: Refine the inet_select_addr codes
Date: Fri, 10 Mar 2017 10:52:21 +0800
Message-ID: <1489114341-7285-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg340.qq.com ([14.17.44.35]:58062 "EHLO smtpbg340.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752621AbdCJCyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 21:54:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

This collection contains two patches used to refine the inet_select_addr codes.


Gao Feng (2):
  net: Avoid unnessary loop when master_idx is invalid in
    inet_select_addr
  net: Eliminate duplicated codes by creating one new function    
    in_dev_select_addr

 net/ipv4/devinet.c | 71 ++++++++++++++++++++++++++++++------------------------
 1 file changed, 39 insertions(+), 32 deletions(-)

-- 
 v3: Add the cover letter, per David
 v2: Correct the comit log and remove useless braces, per Sergei
 v1: Initial Version

1.9.1
