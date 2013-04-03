From: David Miller <davem@davemloft.net>
Subject: Re: TCP: snd_cwnd is nul, please report this bug.
Date: Wed, 03 Apr 2013 13:08:46 -0400 (EDT)
Message-ID: <20130403.130846.1952148767156776528.davem@davemloft.net>
References: <20130403035428.GA31709@redhat.com>
	<1364965967.5113.195.camel@edumazet-glaptop>
	<CAK6E8=cLLsBYkYPgNwL08-BWsG+eR0Jkkck9S7e1Ts0RzfVHLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davej@redhat.com, netdev@vger.kernel.org,
	ncardwell@google.com, nanditad@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758771Ab3DCRIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 13:08:51 -0400
In-Reply-To: <CAK6E8=cLLsBYkYPgNwL08-BWsG+eR0Jkkck9S7e1Ts0RzfVHLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 3 Apr 2013 10:01:32 -0700

> On Tue, Apr 2, 2013 at 10:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2013-04-02 at 23:54 -0400, Dave Jones wrote:
>>> Just had this warning on 3.9-rc5
>>>
>>> Not sure what else to report.  Nothing really odd going on,
>>> just some ssh traffic and firefox over wifi (iwlwifi)
>>>
>>> anything else I can provide ?
> How did you get this warning? is this a WARN_ON?

net/ipv4/tcp_cong.c:		pr_err_once("snd_cwnd is nul, please report this bug.\n");
