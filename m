From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 5/8] net_sched: init struct tcf_hashinfo at
 register time
Date: Wed, 18 Dec 2013 09:37:41 -0500
Message-ID: <52B1B335.30709@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com> <1387167311-14763-6-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:44035 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301Ab3LROhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:37:43 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so10403369iec.9
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:37:42 -0800 (PST)
In-Reply-To: <1387167311-14763-6-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/13 23:15, Cong Wang wrote:
> It looks weird to store the lock out of the struct but
> still points to a static variable. Just move them into the struct.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Looks good - thanks.


Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
