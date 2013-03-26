From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Eulerkernel] [PATCH] af_unix: dont send SCM_CREDENTIAL when
 dest socket is NULL
Date: Tue, 26 Mar 2013 06:46:37 -0700
Message-ID: <1364305597.1716.13.camel@edumazet-glaptop>
References: <515026DA.7050306@huawei.com>
	  <1364220269.29473.13.camel@edumazet-glaptop> <51511148.4000804@huawei.com>
	 <1364272360.1716.11.camel@edumazet-glaptop> <515187F6.4030905@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Li Zefan <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:59086 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934414Ab3CZNqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 09:46:40 -0400
Received: by mail-ie0-f172.google.com with SMTP id c10so8934219ieb.31
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 06:46:39 -0700 (PDT)
In-Reply-To: <515187F6.4030905@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-26 at 19:35 +0800, dingtianhong wrote:

> I think if not call scm_set_creds(), the credential would useles in recvmsg().
> we could remove code:
> 		if (check_creds) {
>                         /* Never glue messages from different writers */
>                         if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
>                             (UNIXCB(skb).cred != siocb->scm->cred))
>                                 break;
>                 } else {
>                         /* Copy credentials */
>                         scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
>                         check_creds = 1;
>                 }

Are you paraphrasing me or saying something different ?
 
