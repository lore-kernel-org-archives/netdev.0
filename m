From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net_sched: act: remove headers in
 include/net/tc_act/
Date: Tue, 14 Jan 2014 17:11:50 -0800
Message-ID: <1389748310.31367.298.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389747699-32508-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f169.google.com ([209.85.161.169]:41516 "EHLO
	mail-gg0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbaAOBLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:11:54 -0500
Received: by mail-gg0-f169.google.com with SMTP id j5so329239ggn.0
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 17:11:53 -0800 (PST)
In-Reply-To: <1389747699-32508-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 17:01 -0800, Cong Wang wrote:
> These headers are not necessary because those definitions in them
> are action specific and are not shared for others. Just move them
> into the C files.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

I find this change very dubious.
