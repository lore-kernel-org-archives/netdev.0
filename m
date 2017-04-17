From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] kcm: remove a useless copy_from_user()
Date: Mon, 17 Apr 2017 13:28:58 -0400 (EDT)
Message-ID: <20170417.132858.1476125185920937797.davem@davemloft.net>
References: <1492108682-30505-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55792 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752223AbdDQR3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:29:00 -0400
In-Reply-To: <1492108682-30505-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 13 Apr 2017 11:38:02 -0700

> struct kcm_clone only contains fd, and kcm_clone() only
> writes this struct, so there is no need to copy it from user.
> 
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
