From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net PATCH] net: sched: fix act_ipt for LOG target
Date: Thu, 3 Mar 2016 09:25:01 -0500
Message-ID: <56D8493D.9060801@mojatatu.com>
References: <1457012054-18012-1-git-send-email-psutter@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Phil Sutter <phil@nwl.cc>
To: Phil Sutter <psutter@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33138 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932217AbcCCOZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 09:25:03 -0500
Received: by mail-io0-f173.google.com with SMTP id n190so28816452iof.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 06:25:03 -0800 (PST)
In-Reply-To: <1457012054-18012-1-git-send-email-psutter@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-03 08:34 AM, Phil Sutter wrote:
> From: Phil Sutter <phil@nwl.cc>
>
> Before calling the destroy() or target() callbacks, the family parameter
> field has to be initialized. Otherwise at least the LOG target will
> refuse to work and upon removal oops the kernel.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Caveat: ipt has not been receiving a lot of love. Thanks for showing
it some love. If indeed you have tested this with the LOG target, then:

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
