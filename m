From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v2] ipv6: delete protocol and unregister rtnetlink when cleanup
Date: Wed, 19 Nov 2014 11:46:55 -0800
Message-ID: <CAHA+R7OtQVgFwUjMPszW6ze3ts6FiWWCHQZ=3ad8U3AuJxqDtA@mail.gmail.com>
References: <546B20F8.6010806@cn.fujitsu.com>
	<CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
	<546BF3EB.1080603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:50242 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279AbaKSTq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 14:46:56 -0500
Received: by mail-qa0-f47.google.com with SMTP id s7so913637qap.34
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 11:46:56 -0800 (PST)
In-Reply-To: <546BF3EB.1080603@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 5:35 PM, Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:
>
>
> pim6_protocol was added when initiation, but it not deleted.
> Similarly, unregister RTNL_FAMILY_IP6MR rtnetlink.
>
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
> v2: add missing rtnl_unregister()

Reviewed-by: Cong Wang <cwang@twopensource.com>
