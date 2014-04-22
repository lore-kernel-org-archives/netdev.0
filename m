From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next] vlan: Don't allow vlan devices to change
 network namespaces.
Date: Tue, 22 Apr 2014 07:26:59 -0700
Message-ID: <1398176819.29946.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398170586-6668-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Chen Weilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32916 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756160AbaDVO1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 10:27:01 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so5005419pab.36
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 07:27:00 -0700 (PDT)
In-Reply-To: <1398170586-6668-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-22 at 20:43 +0800, Chen Weilong wrote:
> From: Weilong Chen <chenweilong@huawei.com>
> 
> Like bonding, vlan as netdevice doesn't cross netns boundaries.
> 
> Vlan port and vlan itself live in same netns.

Please explain why you believe it should be like that.

bonding and vlan have quite different purpose, so your changelog is
quite obscure.

We had a discussion like this one with macvlan, and prior patch was
rejected.
