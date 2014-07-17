From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: hold tcf_lock in netdevice notifier
Date: Thu, 17 Jul 2014 08:49:57 -0400
Message-ID: <53C7C675.7090400@mojatatu.com>
References: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com> <1405545931-13832-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:37833 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756043AbaGQMt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 08:49:59 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so2779502iec.30
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 05:49:59 -0700 (PDT)
In-Reply-To: <1405545931-13832-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/14 17:25, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
>
> We modify mirred action (m->tcfm_dev) in netdev event, we need to
> prevent on-going mirred actions from reading freed m->tcfm_dev.
> So we need to acquire this spin lock.
>

Cong,

What setup prompted this? We have no problems dealing with deleted
devices in the data path. It seems harmless otherwise.

cheers,
jamal
