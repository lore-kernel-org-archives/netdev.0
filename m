From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 22/27] sctp: add rfc6525 section 5.2.4
Date: Sun, 01 Jan 2017 11:32:13 -0500 (EST)
Message-ID: <20170101.113213.663892510185061837.davem@davemloft.net>
References: <470b9f2b5248e0c1870c501f262a1887be66509b.1483269426.git.lucien.xin@gmail.com>
        <201701012026.kWKIK4Hy%fengguang.wu@intel.com>
        <CADvbK_dV2=uJfoPPMHj1nEYvGKvhszgmHOttN7CVgrPWxb2EeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkp@intel.com, kbuild-all@01.org, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, marcelo.leitner@gmail.com,
        nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37936 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932066AbdAAQcP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 11:32:15 -0500
In-Reply-To: <CADvbK_dV2=uJfoPPMHj1nEYvGKvhszgmHOttN7CVgrPWxb2EeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun, 1 Jan 2017 21:26:47 +0800

> As only when the result is not performed, initial_tsn variables is
> uninitialized, peer side would ignore this value, so here is also
> safe.

It doesn't matter if it is "safe" or not, you must fix all of the
warnings reported by kbuild before your patches will be considered
for applying.
