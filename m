From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 4/6] net_sched: cls_flow: remove faulty use of
 list_for_each_entry_rcu
Date: Wed, 03 Dec 2014 08:02:17 -0500
Message-ID: <547F09D9.5050309@mojatatu.com>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us> <1417539636-12710-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:46148 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbaLCNCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:02:20 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so12670994igi.6
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 05:02:19 -0800 (PST)
In-Reply-To: <1417539636-12710-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/14 12:00, Jiri Pirko wrote:
> rcu variant is not correct here. The code is called by updater (rtnl
> lock is held), not by reader (no rcu_read_lock is held).
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Same comment as other one..
I actually i am not so sure about the get_ either.
The core may end up invoking that first before doing a del
so for consistency we need rcu version.

cheers,
jamal
