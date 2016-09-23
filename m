From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] i40e: fix call of ndo_dflt_bridge_getlink()
Date: Fri, 23 Sep 2016 11:12:09 +0200
Message-ID: <60c90efd-fab3-84cd-f6e1-f6bc710c5ab7@6wind.com>
References: <1474301694-13477-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Huaibin Wang <huaibin.wang@6wind.com>,
        Scott Feldman <sfeldma@gmail.com>,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Catherine Sullivan <catherine.sullivan@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36161 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030392AbcIWJMM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 05:12:12 -0400
Received: by mail-wm0-f42.google.com with SMTP id w84so19075884wmg.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 02:12:11 -0700 (PDT)
In-Reply-To: <1474301694-13477-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/09/2016 à 18:14, Nicolas Dichtel a écrit :
> From: Huaibin Wang <huaibin.wang@6wind.com>
> 
> Order of arguments is wrong.
> The wrong code has been introduced by commit 7d4f8d871ab1, but is compiled
> only since commit 9df70b66418e.
> 
> Note that this may break netlink dumps.
> 
> Fixes: 9df70b66418e ("i40e: Remove incorrect #ifdef's")
> Fixes: 7d4f8d871ab1 ("switchdev; add VLAN support for port's bridge_getlink")
> CC: Scott Feldman <sfeldma@gmail.com>
> CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
> CC: Catherine Sullivan <catherine.sullivan@intel.com>
> Signed-off-by: Huaibin Wang <huaibin.wang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Hi Jeff,

any news about this patch? David has marked it "awaiting upstream" on the
patchwork, so I understand it should go to your tree.


Thank you,
Nicolas
