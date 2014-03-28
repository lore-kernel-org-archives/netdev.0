From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/3] netpoll: Use skb_irq_freeable to make zap_completion_queue
 safe.
Date: Fri, 28 Mar 2014 17:17:53 +0400
Message-ID: <53357681.9050200@cogentembedded.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>	<20140317.154916.2276987764507311378.davem@davemloft.net>	<87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>	<1395149407.22343.8.camel@deadeye.wl.decadent.org.uk>	<87lhw7inzg.fsf@nemi.mork.no>	<1395156229.9114.35.camel@edumazet-glaptop2.roam.corp.google.com>	<2c96faab-4293-4e7f-b8e0-4997af745fbf@email.android.com>	<063D6719AE5E284EB5DD2968C1650D6D0F6E02DB@AcuExch.aculab.com>	<87mwgbkttv.fsf_-_@x220.int.ebiederm.org> <8761mzktj9.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?=27Bj=F8rn_Mork=27?= <bjorn@mork.no>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"mpm@selenic.com" <mpm@selenic.com>,
	"satyam.sharma@gmail.com" <satyam.sharma@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:34620 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbaC1NRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 09:17:52 -0400
Received: by mail-lb0-f178.google.com with SMTP id s7so3614439lbd.23
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 06:17:50 -0700 (PDT)
In-Reply-To: <8761mzktj9.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 28-03-2014 5:20, Eric W. Biederman wrote:

> Replace the test in zap_completion_queu to test when it is safe to

    Small typo: it's zap_completion_queue().

> free skbs in hard irq context with skb_irq_freeable ensuring we only
> free skbs when it is safe, and removing the possibility of subtle
> problems.

> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

WBR, Sergei
