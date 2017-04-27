From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] ipv4: get rid of ip_ra_lock
Date: Thu, 27 Apr 2017 05:46:19 -0700
Message-ID: <1493297179.6453.105.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493240115-779-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33837 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755535AbdD0MqW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 08:46:22 -0400
Received: by mail-pf0-f196.google.com with SMTP id g23so9912552pfj.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 05:46:21 -0700 (PDT)
In-Reply-To: <1493240115-779-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-26 at 13:55 -0700, Cong Wang wrote:
> After commit 1215e51edad1 ("ipv4: fix a deadlock in ip_ra_control")
> we always take RTNL lock for ip_ra_control() which is the only place
> we update the list ip_ra_chain, so the ip_ra_lock is no longer needed,
> we just need to disable BH there.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Looks great, but reading again this code, I believe we do not need to
disable BH at all ?

Thanks.
