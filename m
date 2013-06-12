From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/3] team: remove sychronize_rcu() calls
Date: Wed, 12 Jun 2013 13:01:08 +0200
Message-ID: <20130612110108.GB1852@minipsycho.brq.redhat.com>
References: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
 <20130612.031022.382642269781263103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edumazet@google.com, fbl@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:51526 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab3FLLBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 07:01:14 -0400
Received: by mail-ea0-f179.google.com with SMTP id b15so5640424eae.38
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 04:01:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130612.031022.382642269781263103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 12, 2013 at 12:10:22PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 10 Jun 2013 17:42:22 +0200
>
>> Jiri Pirko (3):
>>   team: remove synchronize_rcu() called during queue override change
>>   team: use kfree_rcu instead of synchronize_rcu in team_port_dev
>>   team: remove synchronize_rcu() called during port disable
>
>Applied, but I suspect this patch series was generated against the
>patch set you submitted for "net" because I had to hand apply patch
>#3 with some fuzz as git would not apply it directly.
>
>Please don't do that, submit your patches in the future against what
>is actually in net-next.

Sorry. I will be more careful next time.

Jiri
